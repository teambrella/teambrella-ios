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

    lazy private var session: URLSession = {
        let config = URLSessionConfiguration.default
        //URLSessionConfiguration.background(withIdentifier: "com.blockchainServer.session")
        return URLSession(configuration: config)
    }()
    
    init() {
    }
    
    func initTimestamp(completion:@escaping (Int64?, Error?) -> Void) {
        guard let url = url(string: "me/GetTimestamp") else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let task = session.dataTask(with: request) { data, response, error in
            guard let value = data, error == nil else {
                queue.async {
                    completion(nil, error)
                }
                return
            }

            log("BlockChain server init timestamp reply: \(value)", type: .cryptoRequests)
            do {
                let status = try JSONDecoder().decode(TimestampReplyServerImpl.self, from: value)
                self.timestamp = status.status.timestamp
                queue.async {
                    completion(status.status.timestamp, nil)
                }
            } catch {
                queue.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
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

        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let `self` = self else { return }
            guard let data = data, error == nil else {
                queue.async {
                    completion(nil, error)
                }
                return
            }

            log("Success getting updates with \(updateInfo)", type: .cryptoDetails)
            do {
                let result = try JSONDecoder().decode(GetUpdatesReplyServerImpl.self, from: data)
                let res = try JSONSerialization.jsonObject(with: data, options: [])
                log("Get updates: \(res)", type: .cryptoRequests)
                self.timestamp = result.status.timestamp
                queue.async {
                    completion(result, nil)
                }
            } catch {
                log("Get updates parsing error: \(error)", type: [.error, .crypto])
                let data = try? JSONSerialization.jsonObject(with: data, options: [])
                log("Data is of wrong format, trying to parse JSON object: \(String(describing: data))", type: .cryptoDetails)
                queue.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func postTxExplorer(tx: String,
                        urlString: String,
                        success: @escaping (_ txid: String) -> Void,
                        failure: @escaping () -> Void) {
        let queryPath = "/api/tx/send"
        guard let url = URL(string: urlString + queryPath) else { fatalError() }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "application/json, text/plain, * / *", forHTTPHeaderField: "Accept")
        let body: [String: Any] = ["rawTx": tx]
        if let data = try? JSONSerialization.data(withJSONObject: body, options: []) {
            request.httpBody = data
        }

        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                queue.async {
                    failure()
                }
                return
            }

            queue.async {
                if let txID = String(data: data, encoding: .utf8) {
                    success(txID)
                } else {
                    failure()
                }
            }
        }
        task.resume()
    }
    
    func fetch(urlString: String, success: @escaping (_ result: Data) -> Void, failure: @escaping (Error?) -> Void) {
        guard let url = url(string: urlString) else { fatalError() }
        
        let request = URLRequest(url: url)
        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let task = session.dataTask(with: request) { data, response, error in
            queue.async {
                guard let data = data, error == nil else {
                    failure(error)
                    return
                }

                success(data)
            }
        }
        task.resume()
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
        var request = URLRequest(url: url)
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

        request.httpMethod = "POST"
        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main

        let task = session.uploadTask(with: request, from: data) { data, response, error in
            queue.async {
                guard let data = data, error == nil else {
                    failure(error)
                    return
                }

                success(data)
            }
        }
        task.resume()
    }

    private func request(string: String, key: Key, payload: [String: Any]? = nil) -> URLRequest {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

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
        request.httpMethod = "POST"

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

    private func url(string: String) -> URL? {
        return URL(string: Constant.siteURL + "/" + string)
    }
    
}
