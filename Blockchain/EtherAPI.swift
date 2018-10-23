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

struct EthereumAPIReply: Codable {
    let jsonrpc: String?
    let error: EthereumError?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc = "jsonrpc"
        case error = "error"
        case result = "result"
    }
}

struct EthereumError: Codable, Error {
    let code: Int
    let message: String
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case data = "data"
    }
}

struct EthereumTxReceiptReply: Codable {
    let jsonrpc: String
    let error: EthereumError?
    let result: TxReceipt?
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc = "jsonrpc"
        case error = "error"
        case result = "result"
    }
}
struct TxReceipt: Codable {
    let blockNumber: String
    let gasUsed: String
    let contractAddress: String
    
}

class EtherAPI {
    enum EtherAPIError: Error {
        case malformedURL
        case corruptedData
        case noData
        case etherscanError(Int, String)
        case unknownError
    }
    
    typealias successClosure = (String) -> Void
    typealias failureClosure = (Error) -> Void
    
    let server: String
    
    init(server: String?) {
        self.server = server ?? "https://api.etherscan.io/"
    }
    
    deinit {
        log("EtherAPI dies", type: .cryptoDetails)
    }
    
    //lazy var session = { URLSession.shared }()
    
    // https://api.etherscan.io/api?module=proxy&action=eth_sendRawTransaction&hex=0xf904808000831cfde080&apikey=YourApiKeyToken
    func pushTx(hex: String, success: @escaping (String) -> Void, failure: @escaping failureClosure) {
        /*
         {
         "jsonrpc": "2.0",
         "error": {
         "code": -32010,
         "message": "Transaction nonce is too low. Try incrementing the nonce.",
         "data": null
         },
         "id": 1
         {
         "jsonrpc": "2.0",
         "result": "0x918a3313e6c1c5a0068b5234951c916aa64a8074fdbce0feOocbb5c9797f7332f6",
         "id": 1
         }
         */
        
        log("Pushing tx to etherscan", type: .cryptoRequests)
        sendPostRequest(urlString: "api",
                        parameters:[
                            "module": "proxy",
                            "action": "eth_sendRawTransaction"
            ],
                        body: ["hex": hex],
                        success: { string in
                            log("Pushed tx result: \(string)", type: .cryptoDetails)
                            success(string)
        }) { error in
            log("Push tx error: \(error)", type: [.cryptoDetails, .error])
            failure(error)
        }
    }
    
    func checkNonce(address: String, success: @escaping successClosure, failure: @escaping failureClosure) {
        sendGetRequest(urlString: "api",
                       parameters: [
                        "module": "proxy",
                        "action": "eth_getTransactionCount",
                        "address": address],
                       success: { string in
                        log("nonce for address: \(address) is: \(string)", type: .cryptoDetails)
                        success(string)
        }) { error in
            failure(error)
        }
    }
    
    func checkTx(hash: String, success: @escaping (TxReceipt) -> Void, failure: @escaping failureClosure) {
        let parameters: [String: String] = [
            "module": "proxy",
            "action": "eth_getTransactionReceipt",
            "txHash": hash
        ]
        guard let url = urlWith(address: server + "api", parameters: parameters) else {
            failure(EtherAPIError.malformedURL)
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        log("check tx hash \(hash) with request: \(request)", type: .cryptoRequests)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                failure(error ?? EtherAPIError.noData)
                return
            }
            
            do {
                let reply = try JSONDecoder().decode(EthereumTxReceiptReply.self, from: data)
                if let result = reply.result {
                    success(result)
                } else if let error = reply.error {
                    failure(EtherAPIError.etherscanError(error.code, error.message))
                } else {
                    failure(EtherAPIError.corruptedData)
                }
            } catch {
                failure(error)
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func readContractString(to: String, callDataString: String) -> Future<String> {
        let promise = Promise<String>()
        log("read contract to: \(to), callData: \(callDataString)", type: .cryptoRequests)
        sendGetRequest(urlString: "api",
                       parameters: [
                        "module": "proxy",
                        "action": "eth_call",
                        "to": to,
                        "data": callDataString],
                       success: { string in
                        promise.resolve(with: string)
        }) { error in
            promise.reject(with: error)
        }
        return promise
    }
    
    func checkBalance(address: String, success: @escaping (Decimal) -> Void, failure: @escaping failureClosure) {
        log("Checking balance for: \(address)", type: .cryptoRequests)
        sendGetRequest(urlString: "api",
                       parameters: [
                        "module": "account",
                        "action": "balance",
                        "address": address],
                       success: { string in
                        guard var balance = Decimal(string: string) else {
                            failure(EtherAPIError.corruptedData)
                            return
                        }
                        log("Balance received: \(string)", type: .cryptoDetails)
                        balance = balance / 1_000_000_000_000_000_000
                        log("Balance converted: \(balance)", type: .cryptoDetails)
                        success(balance)
        }) { error in
            failure(error)
        }
    }
    
    // MARK: Private
    
    private func sendPostRequest(urlString: String,
                                 parameters: [String: String],
                                 body: [String: String],
                                 success: @escaping successClosure,
                                 failure: @escaping failureClosure) {
        //        var parameters = parameters
        //        for (key, value) in body {
        //            parameters[key] = value
        //        }
        guard let url = urlWith(address: server + urlString, parameters: parameters) else {
            failure(EtherAPIError.malformedURL)
            return
        }
        
        let queue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let bodyArray = body.map { key, value in """
            \(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\
            \(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            """
        }
        let bodyString = bodyArray.joined(separator: "&")
        let bodyData = bodyString.data(using: .utf8, allowLossyConversion: true)
        
        log("Body string: \(bodyString)", type: .cryptoDetails)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                queue.async {
                    failure(error ?? EtherAPIError.unknownError)
                }
                return
            }
            
            log("raw post request reply: \(data)", type: .cryptoRequests)
            do {
                let reply = try JSONDecoder().decode(EthereumAPIReply.self, from: data)
                queue.async {
                    if let result = reply.result {
                        success(result)
                    } else if let error = reply.error {
                        failure(EtherAPIError.etherscanError(error.code, error.message))
                    } else {
                        failure(EtherAPIError.corruptedData)
                    }
                }
            } catch {
                queue.async {
                    failure(error)
                }
            }
            
        }
        log("Sending request: \(task.currentRequest)", type: .cryptoRequests)
        log("HTTP fields: \(task.currentRequest?.allHTTPHeaderFields)", type: .cryptoDetails)
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func sendGetRequest(urlString: String,
                                parameters: [String: String],
                                success: @escaping successClosure,
                                failure: @escaping failureClosure) {
        guard let url = urlWith(address: server + urlString, parameters: parameters) else {
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
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                failure(error ?? EtherAPIError.noData)
                return
            }
            do {
                let reply = try JSONDecoder().decode(EthereumAPIReply.self, from: data)
                if let result = reply.result {
                    success(result)
                } else if let error = reply.error {
                    failure(EtherAPIError.etherscanError(error.code, error.message))
                } else {
                    failure(EtherAPIError.corruptedData)
                }
            } catch {
                log("EthereumAPIReply parsing error: \(error)", type: .error)
                failure(error)
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func urlWith(address: String, parameters: [String: String]) -> URL? {
        let urlComponents = NSURLComponents(string: address)
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.url
    }
    
}
