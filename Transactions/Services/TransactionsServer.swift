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

public protocol TransactionsServerDelegate: class {
    func server(server: TransactionsServer, didUpdateTimestamp timestamp: Int64)
    func serverInitialized(server: TransactionsServer)
    func server(server: TransactionsServer, didReceiveUpdates updates: JSON)
    func server(server: TransactionsServer, failedWithError error: Error?)
}

public class TransactionsServer {
    struct Constant {
        static let siteURL = "http://192.168.0.254" //"http://surilla.com"
        static let fakePrivateKey = "Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
        
    }
    
    weak var delegate: TransactionsServerDelegate?
    
    private(set)var timestamp: Int64 = 0 {
        didSet {
            print("timestamp updated from \(oldValue) to \(timestamp)")
            delegate?.server(server: self, didUpdateTimestamp: timestamp)
        }
    }
    
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
    
    func initClient(privateKey: String) {
        initTimestamp { [weak self] timestamp in
            guard let me = self else { return }
            guard let key = Key(base58String: privateKey, timestamp: timestamp) else { return }
            
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
                        me.delegate?.serverInitialized(server: me)
                    }
                case .failure(let error):
                    me.delegate?.server(server: me, failedWithError: error)
                }
            }
        }
    }
    
    func getUpdates(privateKey: String,
                    lastUpdated: Int64,
                    transactions: [BitcoinTransaction],
                    signatures: [BitcoinTransactionSignature]) {
        guard let key = Key(base58String: privateKey, timestamp: timestamp) else { return }
        
        let txInfos = transactions.map { ["Id": $0.id,
                                          "ResolutionTime": $0.clientResolutionTime?.timeIntervalSince1970 ?? 0,
                                          "Resolution": $0.resolution] }
        let txSignatures = signatures.map {
            ["Signature": $0.signature.base64EncodedString(),
             "TeammateId": $0.teammate.id,
             "TxInputId": $0.transactionInput.id]
        }
        let payload = ["TxInfos": txInfos,
                       "TxSignatures": txSignatures]
        let request = self.request(string: "me/GetUpdates", key: key, payload: payload)
        Alamofire.request(request).responseJSON { [weak self] response in
            guard let me = self else { return }
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print(value)
                    let result = JSON(value)
                    if let timestamp = result["Timestamp"].int64 {
                        me.timestamp = timestamp
                    }
                    me.delegate?.server(server: me, didReceiveUpdates: result)
                }
            case .failure(let error):
                me.delegate?.server(server: me, failedWithError: error)
            }
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
            print("colud not create data from payload: \(body)")
        }
        return request
    }
    
    private func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
