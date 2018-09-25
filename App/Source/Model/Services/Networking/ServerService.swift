//
//  ServerService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.

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
 Service to interoperate with the server fetching all UI related information
 */
final class ServerService: NSObject {
    @objc dynamic private(set)var timestamp: Int64 = 0
    var router: MainRouter
    var infoMaker: InfoMaker
    var key: Key { return Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp) }
    
    lazy private var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(20)
        config.timeoutIntervalForResource = TimeInterval(60)
        return URLSession(configuration: config)
    }()
    
    required init(router: MainRouter, infoMaker: InfoMaker) {
        self.router = router
        self.infoMaker = infoMaker
        super.init()
    }
    
    func updateTimestamp(completion: @escaping (Int64, Error?) -> Void) {
        let timestampFetcher = TimestampFetcher()
        timestampFetcher.requestTimestamp { timestamp, error in
            guard error == nil else {
                completion(0, error)
                return
            }
            
            self.timestamp = timestamp
            completion(timestamp, nil)
        }
    }
    
    func get(string: String,
             parameters: [String: String],
             success: @escaping (Data) -> Void,
             failure: @escaping (Error) -> Void) {
        guard let url = URLBuilder().url(for: string, parameters: parameters) else {
            fatalError("Couldn't create URL for get request")
        }
        
        var request = URLRequest(url: url)
        log(url.absoluteString, type: .serverURL)
        request.httpMethod = "GET"
        
        let queue = DispatchQueue.main
        
        let task = session.dataTask(with: request) { data, response, error in
            queue.async {
                if let error = error {
                    failure(error)
                    return
                }
                guard let value = data else {
                    failure(TeambrellaErrorFactory.emptyReplyError())
                    return
                }
                
                success(value)
            }
        }
        task.resume()
    }
    
    // swiftlint:disable:next function_body_length
    func ask(for string: String,
             parameters: [String: String]? = nil,
             body: RequestBody? = nil,
             success: @escaping (ServerReply) -> Void,
             failure: @escaping (Error) -> Void) {
        
        guard let url = URLBuilder().url(for: string, parameters: parameters) else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        log(url.absoluteString, type: .serverURL)
        request.httpMethod = "POST"
        let contentType = body?.contentType ?? "application/json"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            if let data = body.data {
                request.httpBody = data
            } else if let data = try? JSONSerialization.data(withJSONObject: body.dictionary,
                                                             options: []) {
                request.httpBody = data
                printAsString(data: data)
            }
            let application = Application()
            let dict: [String: Any] = ["t": body.timestamp,
                                       "key": body.publicKey,
                                       "sig": body.signature,
                                       "clientVersion": application.clientVersion,
                                       "deviceToken": service.push.tokenString ?? "",
                                       "pushKitToken": service.push.pushKit.tokenString,
                                       "deviceId": application.uniqueIdentifier,
                                       "info": infoMaker.info]
            
            log("Headers:", type: .serverHeaders)
            for (key, value) in dict {
                log("\(key): \(value)", type: .serverHeaders)
                request.setValue(String(describing: value), forHTTPHeaderField: key)
            }
        }
        
        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                queue.async {
                    failure(error)
                }
                return
            }
            guard let value = data else {
                queue.async {
                    failure(TeambrellaErrorFactory.emptyReplyError())
                }
                return
            }
            
            do {
                let reply = try ServerReply(data: value)
                guard reply.status.isValid else {
                    let error = TeambrellaErrorFactory.error(with: reply.status)
                    queue.async {
                        failure(error)
                    }
                    return
                }
                
                queue.async {
                    success(reply)
                }
                
                let manager = SODManager(router: self.router)
                manager.checkVersion(serverReply: reply)
            } catch {
                queue.async {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    private func printAsString(data: Data?) {
        guard let data = data else { return }
        
        if let string = try? JSONSerialization.jsonObject(with: data, options: []) {
            log("\(string)", type: .serverRequest)
        }
    }
    
}
