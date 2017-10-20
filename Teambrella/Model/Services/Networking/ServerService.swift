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

import Alamofire
import Foundation
import SwiftyJSON

struct ResponseStatus {
    let timestamp: Int64
    let code: Int
    let errorMessage: String
    
    init(json: JSON) {
        timestamp = json["Timestamp"].int64Value
        code = json["ResultCode"].intValue
        errorMessage = json["ErrorMessage"].stringValue
    }
}

#if SURILLA
let isLocalServer = true
#else
let isLocalServer = false
#endif

/**
 Service to interoperate with the server fetching all UI related information
 */
class ServerService: NSObject {
    struct Constant {
        static var siteURL: String { return isLocalServer ? "https://surilla.com" : "https://teambrella.com" }
        static let timestampURL = "me/GetTimestamp"
    }
    
    //    enum FakeKeyType: String {
    //        case denis = "cNqQ7aZWitJCk1o9dNhr1o9k3UKdeW92CDYrvDHHLuwFuEnfcBXo"
    //        case kate = "cUNX4HYHK3thsjDKEcB26qRYriw8uJLtt8UvDrM98GbUBn22HMrY"
    //        case thorax = "93ProQDtA1PyttRz96fuUHKijV3v2NGnjPAxuzfDXwFbbLBYbxx"
    //        case eugene = "L4TzGwABRFtqGBtrbKxK1ZHEByi3GczUhztEx9dtPvXkuAzGKGdo"
    //        case testUser = "Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
    //
    //    }
    
    // static var currentKeyType: FakeKeyType = .testUser
    static var teamID: Int { return service.session?.currentTeam?.teamID ?? 0 }
    
    static var privateKey: String {
        return service.keyStorage.privateKey
    }
    
    @objc dynamic private(set)var timestamp: Int64 = 0 
    
    var key: Key { return Key(base58String: ServerService.privateKey, timestamp: timestamp) }
    
    override init() {
        super.init()
    }
    
    func avatarURLstring(for string: String,
                         width: CGFloat? = 128,
                         crop rect: CGRect? = CGRect(x: 0, y: 0, width: 128, height: 128)) -> String {
        var urlString = Constant.siteURL + string
        if let width = width {
            let rect = rect ?? CGRect(x: 0, y: 0, width: width, height: width)
            urlString += "?width=\(width)&crop=\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height)"
        }
        return urlString
    }
    
    func updateTimestamp(completion: @escaping (Int64, Error?) -> Void) {
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
                    let result = JSON(value)
                    self.timestamp = result["Status"]["Timestamp"].int64Value
                }
                completion(self.timestamp, nil)
            case .failure(let error):
                completion(0, error)
            }
        }
    }
    
    func url(for string: String, parameters: [String: String]?) -> URL? {
        var urlComponents = URLComponents(string: urlString(string: string))
        if let parameters = parameters {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters {
                guard let key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        continue
                }
                
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents?.queryItems = queryItems
        }
        return urlComponents?.url
    }
    
    func ask(for string: String,
             parameters: [String: String]? = nil,
             body: RequestBody? = nil,
             success: @escaping (JSON) -> Void,
             failure: @escaping (Error) -> Void) {
        
        guard let url = url(for: string, parameters: parameters) else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        
        log(url.absoluteString, type: .serverURL)
        
        request.httpMethod = HTTPMethod.post.rawValue
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
            request.setValue("\(body.timestamp)", forHTTPHeaderField: "t")
            request.setValue(body.publicKey, forHTTPHeaderField: "key")
            request.setValue(body.signature, forHTTPHeaderField: "sig")
        }
        
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let result = JSON(value)
                    log("\(result)", type: .serverReply)
                    let status = ResponseStatus(json: result["Status"])
                    self.timestamp = status.timestamp
                    switch status.code {
                    case 0:
                        success(result["Data"])
                    default:
                        let error = TeambrellaErrorFactory.error(with: status)
                        failure(error)
                    }
                } else {
                    let error = TeambrellaErrorFactory.emptyReplyError()
                    failure(error)
                }
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    private func printAsString(data: Data?) {
        guard let data = data else { return }
        
        if let string = try? JSONSerialization.jsonObject(with: data, options: []) {
            log("\(string)", type: .requestBody)
        }
    }
    
    func urlString(string: String) -> String {
        if string.hasPrefix(Constant.siteURL) {
            return string
        }
        if string.hasPrefix("/") {
            return Constant.siteURL + string
        }
        return Constant.siteURL + "/" + string
    }
    
    func url(string: String) -> URL? {
        return URL(string: urlString(string: string))
    }
    
}
