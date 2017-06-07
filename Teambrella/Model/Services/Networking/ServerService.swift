//
//  ServerService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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

/**
 Service to interoperate with the server fetching all UI related information
 */
class ServerService {
    struct Constant {
        static let siteURL = BlockchainServer.Constant.siteURL
        //"http://surilla.com"//"http://192.168.0.254" // "http://192.168.0.222"
        static let fakePrivateKey = "93ProQDtA1PyttRz96fuUHKijV3v2NGnjPAxuzfDXwFbbLBYbxx"
        // "Kxv2gGGa2ZW85b1LXh1uJSP3HLMV6i6qRxxStRhnDsawXDuMJadB"
        static let myID = 2274
        static let myUserID = "1dbd099a-6cc2-4c45-a7df-a75c00e58621"
        static let timestampURL = "me/GetTimestamp"
        static let teamID = 2006
        
    }
    
    private(set)var timestamp: Int64 = 0
    
    init() {
        
    }
    
    func avatarURLstring(for string: String, width: CGFloat? = nil, crop rect: CGRect? = nil) -> String {
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
    
    func ask(for string: String,
             parameters: [String: String]? = nil,
             body: RequestBody? = nil,
             success: @escaping (JSON) -> Void,
             failure: @escaping (Error) -> Void) {
        guard let url = url(string: string) else {
            fatalError("Couldn't create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body, let data = try? JSONSerialization.data(withJSONObject: body.dictionary,
                                                                   options: []) {
            request.httpBody = data
            printAsString(data: data)
            
            request.setValue("\(body.timestamp)", forHTTPHeaderField: "t")
            request.setValue(body.publicKey, forHTTPHeaderField: "key")
            request.setValue(body.signature, forHTTPHeaderField: "sig")
        }
        
        print(request)
        Alamofire.request(request).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let result = JSON(value)
                     print("Result: \(result)")
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
            print(string)
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
