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

/**
 Service to interoperate with the server that would provide all transactions related information
 No UI related information should be received with those calls
 */
public class BlockchainServer {
    struct Constant {
        #if SURILLA
        static let proto = "http://"
        static let site = "surilla.com"
        static let isTestNet = true
        #else
        static let proto = "https://"
        static let site = "teambrella.com"
        static let isTestNet = false
        #endif
        
        static var siteURL: String { return proto + site } // "https://surilla.com"
    }
    
    var isTestnet: Bool = Constant.isTestNet
    
    private(set)var timestamp: Int64 = 0 {
        didSet {
            log("timestamp updated from \(oldValue) to \(timestamp)", type: .cryptoDetails)
        }
    }
    
    lazy var formatter = BlockchainDateFormatter()
    
    init() {
    }
    
    func initTimestamp(completion:@escaping (Int64?, Error?) -> Void) {
        guard let url = url(string: "me/GetTimestamp") else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case let .success(value):
                log("BlockChain server init timestamp reply: \(value)", type: .cryptoRequests)
                do {
                    let status = try JSONDecoder().decode(TimestampReplyServerImpl.self, from: value)
                    self.timestamp = status.status.timestamp
                    completion(status.status.timestamp, nil)
                } catch {
                    completion(nil, error)
                }
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    /*
    func initClient(privateKey: String, completion: @escaping (_ success: Bool) -> Void) {
        initTimestamp { [weak self] timestamp, error in
            guard let me = self else { return }
            guard let timestamp = timestamp else { return }
            guard error == nil else { return }

            let key = Key(base58String: privateKey, timestamp: timestamp)

            let request = me.request(string: "me/InitClient", key: key)
            Alamofire.request(request).responseData { response in
                switch response.result {
                case let .success(value):
                    log("init client reply: \(value)", type: .cryptoRequests)
                    completion(true)
                    /*
                    do {

                        //let status = try JSONDecoder().decode(ServerStatusImpl.self, from: value)
                       // me.timestamp = status.timestamp
                        completion(true)
                    } catch {
                        log("Init client error: \(error)", type: .error)
                        completion(false)
                    }
 */
                case .failure(let error):
                    log("error initializing client: \(error)", type: [.error, .cryptoRequests])
                    completion(false)
                }
            }
        }
    }
    */
    
    func getUpdates(privateKey: String,
                    lastUpdated: Int64,
                    multisigs: [Multisig],
                    transactions: [Tx],
                    signatures: [TxSignature],
                    completion: @escaping (GetUpdatesReplyServerImpl?, Error?) -> Void) {
        let key = Key(base58String: privateKey, timestamp: timestamp)
        let updateInfo = CryptoServerUpdateInfo(multisigs: multisigs,
                                                transactions: transactions,
                                                signatures: signatures,
                                                lastUpdated: lastUpdated,
                                                formatter: formatter)
        log("Get updates updateInfo signatures: \(updateInfo.txSignatures)", type: .cryptoDetails)
        let request = self.request(string: "me/GetUpdates", key: key, updateInfo: updateInfo)
        Alamofire.request(request).responseData { [weak self] response in
            guard let me = self else { return }
            
            switch response.result {
            case let .success(data):
                log("Success getting updates with \(updateInfo)", type: .cryptoDetails)
                do {
                    let result = try JSONDecoder().decode(GetUpdatesReplyServerImpl.self, from: data)
                    me.timestamp = result.status.timestamp
                    completion(result, nil)
                } catch {
                    log("Get updates parsing error: \(error)", type: [.error, .crypto])
                    completion(nil, error)
                }
            case let .failure(error):
                completion(nil, error)
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
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case let .success(value):
                if let txID = String(data: value, encoding: .utf8) {
                    success(txID)
                } else {
                    failure()
                }
            default:
                failure()
            }
        }
    }
    
    func fetch(urlString: String, success: @escaping (_ result: Data) -> Void, failure: @escaping (Error?) -> Void) {
        guard let url = url(string: urlString) else { fatalError() }
        
        let request = URLRequest(url: url)
        Alamofire.request(request).responseData { response in
            switch response.result {
            case let .success(data):
                success(data)
            case let .failure(error):
                failure(error)
            }
        }
    }

    func postData(to urlString: String,
                  data: Data,
                  privateKey: String,
                  success: @escaping (_ result: Data) -> Void,
                  failure: @escaping (Error?) -> Void) {
        guard let url = self.url(string: urlString) else {
            failure(nil)
            return
        }

        let key = Key(base58String: privateKey, timestamp: timestamp)
        //let request: URLRequest = self.postDataRequest(string: urlString, key: key, data: data)
        let application = Application()
        let headers: HTTPHeaders = ["t": "\(timestamp)",
            "key": key.publicKey,
            "sig": key.signature,
            "clientVersion": application.clientVersion,
            "deviceToken": "",
            "deviceId": application.uniqueIdentifier]

        Alamofire.upload(data, to: url, method: .post, headers: headers).responseData { response in
            switch response.result {
            case let .success(value):
                success(value)
            case let .failure(error):
                failure(error)
            }
        }
    }

    private func request(string: String, key: Key, payload: [String: Any]? = nil) -> URLRequest {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

        let application = Application()
        let dict: [String: Any] = ["t": timestamp,
                                   "key": key.publicKey,
                                   "sig": key.signature,
                                   "clientVersion": application.clientVersion,
                                   "deviceToken": "",
                                   "deviceId": application.uniqueIdentifier]
        for (key, value) in dict {
            request.setValue(String(describing: value), forHTTPHeaderField: key)
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String : Any] = [:]/* ["Timestamp": timestamp,
         "Signature": key.signature,
         "PublicKey": key.publicKey] */
        if let payload = payload {
            for (key, value) in payload {
                body[key] = value
            }
        }
        log("request body: \(body)", type: .cryptoRequests)
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
            log("Request: \(url.absoluteURL)", type: .cryptoRequests)
            return request
        } catch {
            log("could not create data from payload: \(body), error: \(error)", type: [.error, .cryptoRequests])
        }
        fatalError()
    }

    private func request(string: String, key: Key, updateInfo: CryptoServerUpdateInfo) -> URLRequest {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

        let application = Application()
        let dict: [String: Any] = ["t": timestamp,
                                   "key": key.publicKey,
                                   "sig": key.signature,
                                   "clientVersion": application.clientVersion,
                                   "deviceToken": "",
                                   "deviceId": application.uniqueIdentifier]
        for (key, value) in dict {
            request.setValue(String(describing: value), forHTTPHeaderField: key)
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(updateInfo)
            request.httpBody = jsonData
            log("Request: \(url.absoluteURL)", type: .cryptoRequests)
            return request
        } catch {
            log("could not create data from updateInfo: ](updateInfo), error: \(error)", type: [.error, .cryptoRequests])
            fatalError()
        }
    }
    
    /*
     private func postDataRequest(string: String, key: Key, data: Data) -> URLRequest {
     guard let url = url(string: string) else {
     fatalError("Couldn't create URL")
     }

     var request = URLRequest(url: url)
     request.httpMethod = HTTPMethod.post.rawValue
     request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
     let application = Application()
     let dict: [String: Any] = ["t": timestamp,
     "key": key.publicKey,
     "sig": key.signature,
     "clientVersion": application.clientVersion,
     "deviceToken": "",
     "deviceId": application.uniqueIdentifier]
     for (key, value) in dict {
     request.setValue(String(describing: value), forHTTPHeaderField: key)
     }
     request.httpBody = data
     print("Request: \(url.absoluteURL) body: data \(data.count)")
     return request
     }
     */

    private func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
