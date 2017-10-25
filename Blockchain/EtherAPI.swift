//
/* Copyright(C) 2017 Teambrella, Inc.
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
import SwiftyJSON

class EtherAPI {
    enum EtherAPIError: Error {
        case malformedURL
        case corruptedData
        case unknown
    }
    
    typealias successClosure = (Data) -> Void
    typealias failureClosure = (Error) -> Void
    
    let server: String
    
    init(server: String?) {
        self.server = server ?? "https://api.etherscan.io/"
    }
    
    lazy var session = { URLSession.shared }()
    
    // https://api.etherscan.io/api?module=proxy&action=eth_sendRawTransaction&hex=0xf904808000831cfde080&apikey=YourApiKeyToken
    func pushTx(hex: String) -> Future<JSON> {
        let promise = Promise<JSON>()
        sendPostRequest(urlString: "api?module=proxy&action=eth_sendRawTransaction",
                        body: ["hex": hex],
                        success: { data in
                            promise.resolve(with: JSON(data))
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    func checkNonce(address: String) -> Future<String> {
        let promise = Promise<String>()
        sendGetRequest(urlString: "api?module=proxy&action=eth_getTransactionCount",
                       parameters: ["address": address],
                       success: { data in
                        let string = String(data: data, encoding: .utf8)
                        promise.resolve(with: string ?? "")
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    func checkTx(hash: String) -> Future<JSON> {
        let promise = Promise<JSON>()
        sendGetRequest(urlString: "api?module=proxy&action=eth_getTransactionReceipt",
                       parameters: ["txHash": hash],
                       success: { data in
                        let json = JSON(data)
                        promise.resolve(with: json)
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    func readContractString(to: String, callDataString: String) -> Future<String> {
        let promise = Promise<String>()
        sendGetRequest(urlString: "api?module=proxy&action=eth_call",
                       parameters: ["to": to, "data": callDataString],
                       success: { data in
                        let string = String(data: data, encoding: .utf8)
                        promise.resolve(with: string ?? "")
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    func checkBalance(address: String) -> Future<Decimal> {
        let promise = Promise<Decimal>()
        sendGetRequest(urlString: "api?module=account&action=balance",
                       parameters: ["address": address],
                       success: { data in
                        guard let string = String(data: data, encoding: .utf8),
                            let balance = Decimal(string: string) else {
                                promise.reject(with: EtherAPIError.corruptedData)
                                return
                        }
                        
                        promise.resolve(with: balance)
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    // MARK: Private
    
    private func sendPostRequest(urlString: String,
                                 body: [String: Any],
                                 success: @escaping successClosure,
                                 failure: @escaping failureClosure) {
        guard let url = URL(string: server + urlString) else {
            failure(EtherAPIError.malformedURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        sendRequest(request, success: success, failure: failure)
    }
    
    private func sendGetRequest(urlString: String,
                                parameters: [String: String],
                                success: @escaping successClosure,
                                failure: @escaping failureClosure) {
        let urlComponents = NSURLComponents(string: server + urlString)
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        guard let url = urlComponents?.url else {
            failure(EtherAPIError.malformedURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request, success: success, failure: failure)
    }
    
    private func sendRequest(_ request: URLRequest,
                             success: @escaping successClosure,
                             failure: @escaping failureClosure) {
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                failure(error ?? EtherAPIError.unknown)
                return
            }
            
            success(data)
        }
        task.resume()
    }
    
}
