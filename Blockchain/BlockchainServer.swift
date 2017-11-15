//
//  TransactionsServer.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Alamofire
import Foundation
import SwiftyJSON

/**
 Service to interoperate with the server that would provide all transactions related information
 No UI related information should be received with those calls
 */
public class BlockchainServer {
    struct Constant {
        #if TEAMBRELLA
        static let proto = "https://"
        static let site = "teambrella.com"
        static let isTestNet = false
        #else
        static let proto = "http://"
        static let site = "surilla.com"
        static let isTestNet = true
        #endif
        
        static var siteURL: String { return proto + site } // "https://surilla.com"
        //"2uGEcr6rkwBBi26NMcuALZSJGZ353ZdgExwbGGXL4xe8"//"Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
    }
    
    enum Response {
        case success(JSON, Int64)
        case failure(Error)
    }
    
    var isTestnet: Bool = Constant.isTestNet
    
    private(set)var timestamp: Int64 = 0 {
        didSet {
            print("timestamp updated from \(oldValue) to \(timestamp)")
        }
    }
    
    lazy var formatter = BlockchainDateFormatter()
    
    init() {
    }
    
    func initTimestamp(completion:@escaping (Response) -> Void) {
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
                    completion(.success(result, timestamp))
                } else {
                    completion(.failure(TeambrellaErrorFactory.emptyReplyError()))
                    //self.delegate?.server(server: self, failedWithError: nil)
                }
            case .failure(let error):
                completion(.failure(error))
                //                self.delegate?.server(server: self, failedWithError: error)
            }
        }
    }
    
    func initClient(privateKey: String, completion: @escaping (_ success: Bool) -> Void) {
        initTimestamp { [weak self] reply in
            guard let me = self else { return }
            switch reply {
            case .success(_, let timestamp):
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
                        print("error initializing client: \(error)")
                        //                        me.delegate?.server(server: me, failedWithError: error)
                        completion(false)
                    }
                }
                
            default: break
            }
        }
    }
    
    func getUpdates(privateKey: String,
                    lastUpdated: Int64,
                    transactions: [Tx],
                    signatures: [TxSignature],
                    completion: @escaping (Response) -> Void) {
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
                    completion(.success( result["Data"], lastUpdated))
                    //                    me.delegate?.server(server: me, didReceiveUpdates: result["Data"], updateTime: lastUpdated)
                }
            case .failure(let error):
                completion(.failure(error))
                //                me.delegate?.server(server: me, failedWithError: error)
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
    
    func fetch(urlString: String, success: @escaping (_ result: JSON) -> Void, failure: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { fatalError() }
        
        let request = URLRequest(url: url)
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case.success:
                if let value = response.result.value {
                    let json = JSON(value)
                    success(json)
                    return
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
