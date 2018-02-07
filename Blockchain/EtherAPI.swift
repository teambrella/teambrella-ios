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
import Alamofire

struct EthereumAPIReply: Codable {
    let jsonrpc: String
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
    
    lazy var session = { URLSession.shared }()
    
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
        
        sendPostRequest(urlString: "api",
                        parameters:[
                            "module": "proxy",
                            "action": "eth_sendRawTransaction"
            ],
                        body: ["hex": hex],
                        success: { string in
                            success(string)
        }) { error in
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

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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
    }
    
    func readContractString(to: String, callDataString: String) -> Future<String> {
        let promise = Promise<String>()
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
                        balance = balance / 1_000_000_000_000_000_000
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
        guard let url = urlWith(address: server + urlString, parameters: parameters) else {
            failure(EtherAPIError.malformedURL)
            return
        }
        
        Alamofire.request(url, method: .post, parameters: body, encoding: URLEncoding.default).responseData { response in
            switch response.result {
            case let .success(data):
                log("raw post request reply: \(data)", type: .cryptoRequests)
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
                    failure(error)
                }
            case let .failure(error):
                failure(error)
            }
        }
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
                failure(error)
            }
        }
        task.resume()
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
