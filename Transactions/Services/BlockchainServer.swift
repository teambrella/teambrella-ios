//
//  TransactionsServer.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

public protocol BlockchainServerDelegate: class {
    func server(server: BlockchainServer, didUpdateTimestamp timestamp: Int64)
    func server(server: BlockchainServer, didReceiveUpdates updates: JSON, updateTime: Int64)
    func server(server: BlockchainServer, failedWithError error: Error?)
}

/**
 Service to interoperate with the server that would provide all transactions related information
 No UI related information should be received with those calls
 */
public class BlockchainServer {
    struct Constant {
        static let siteURL =  "https://surilla.com" // "http://192.168.0.222"//////"http://94.72.4.72"
        //"2uGEcr6rkwBBi26NMcuALZSJGZ353ZdgExwbGGXL4xe8"//"Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
    }
    
    weak var delegate: BlockchainServerDelegate?
    var isTestnet: Bool = true
    
    private(set)var timestamp: Int64 = 0 {
        didSet {
            print("timestamp updated from \(oldValue) to \(timestamp)")
            delegate?.server(server: self, didUpdateTimestamp: timestamp)
        }
    }
    
    lazy var formatter = BlockchainDateFormatter()
    
    init() {
    }
    
    func initTimestamp(completion:@escaping (Int64) -> Void) {
        guard let url = url(string: "me/GetTimestamp") else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print(value)
                    let result = JSON(value)
                    let status = result["Status"]
                    let timestamp = status["Timestamp"].int64Value
                    self.timestamp = timestamp
                    completion(timestamp)
                } else {
                    self.delegate?.server(server: self, failedWithError: nil)
                }
            case .failure(let error):
                self.delegate?.server(server: self, failedWithError: error)
            }
        }
    }
    
    func initClient(privateKey: String, completion: @escaping (_ success: Bool) -> Void) {
        initTimestamp { [weak self] timestamp in
            guard let me = self else { return }
            let key = Key(base58String: privateKey, timestamp: timestamp)
            
            let request = me.request(string: "me/InitClient", key: key)
            Alamofire.request(request).responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        print(value)
                        let result = JSON(value)
                        if let timestamp = result["Timestamp"].int64 {
                            me.timestamp = timestamp
                        }
                        completion(true)
                    }
                case .failure(let error):
                    me.delegate?.server(server: me, failedWithError: error)
                    completion(false)
                }
            }
        }
    }
    
    func getUpdates(privateKey: String,
                    lastUpdated: Int64,
                    transactions: [Tx],
                    signatures: [TxSignature]) {
        let key = Key(base58String: privateKey, timestamp: timestamp)
        
        let txInfos = transactions.map { ["Id": $0.id.uuidString,
                                          "ResolutionTime": formatter.string(from: $0.clientResolutionTime!),
                                          "Resolution": $0.resolution.rawValue ] }
        
        let txSignatures = signatures.map {
            ["Signature": $0.signature.base64EncodedString(),
             "TeammateId": $0.teammateID,
             "TxInputId": $0.inputID]
        }
        let payload: [String: Any] = ["TxInfos": txInfos,
                                      "TxSignatures": txSignatures,
                                      "Since": lastUpdated]
        let request = self.request(string: "me/GetUpdates", key: key, payload: payload)
        Alamofire.request(request).responseJSON { [weak self] response in
            guard let me = self else { return }
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print(value)
                    let result = JSON(value)
                    let timestamp = result["Status"]["Timestamp"].int64Value
                    me.timestamp = timestamp
                    let lastUpdated = result["Data"]["LastUpdated"].int64Value
                    me.delegate?.server(server: me, didReceiveUpdates: result["Data"], updateTime: lastUpdated)
                }
            case .failure(let error):
                me.delegate?.server(server: me, failedWithError: error)
            }
        }
    }
    
    func postTxExplorer(tx: String,
                        urlString: String,
                        success: @escaping (_ txid: String) -> Void,
                        failure: @escaping () -> Void) {
        let queryPath = "/api/tx/send"
        guard let url = URL(string: urlString + queryPath) else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "application/json, text/plain, * / *", forHTTPHeaderField: "Accept")
        let body: [String: Any] = ["rawTx": tx]
        if let data = try? JSONSerialization.data(withJSONObject: body, options: []) {
            request.httpBody = data
        }
        
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case.success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let txid = json.string {
                        success(txid)
                        return
                    }
                }
            default: break
            }
            failure()
        }
        
    }
    
    private func request(string: String, key: Key, payload: [String: Any]? = nil) -> URLRequest {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String : Any] = ["Timestamp": timestamp,
                                    "Signature": key.signature,
                                    "PublicKey": key.publicKey]
        if let payload = payload {
            for (key, value) in payload {
                body[key] = value
            }
        }
        if let data = try? JSONSerialization.data(withJSONObject: body, options: []) {
            request.httpBody = data
        } else {
            print("could not create data from payload: \(body)")
        }
        print("Request: \(url.absoluteURL) body: \(body)")
        return request
    }
    
    private func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
