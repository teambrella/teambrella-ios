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

/**
 Service to interoperate with the server fetching all UI related information
 */
class ServerService: NSObject {
    @objc dynamic private(set)var timestamp: Int64 = 0
    
    var key: Key { return Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp) }
    
    override init() {
        super.init()
    }
    
    func updateTimestamp(completion: @escaping (Int64, Error?) -> Void) {
        let timestampFetcher = TimestampFetcher()
        timestampFetcher.requestTimestamp { timestamp, error in
            guard error == nil else { return }
            
            self.timestamp = timestamp
            completion(timestamp, nil)
        }
    }
    
    // swiftlint:disable:next function_body_length
    func ask(for string: String,
             parameters: [String: String]? = nil,
             body: RequestBody? = nil,
             success: @escaping (JSON) -> Void,
             failure: @escaping (Error) -> Void) {
        
        guard let url = URLBuilder().url(for: string, parameters: parameters) else {
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
            let application = Application()
            let dict: [String: Any] = ["t": body.timestamp,
                        "key": body.publicKey,
                        "sig": body.signature,
                        "clientVersion": application.clientVersion,
                        "deviceToken": service.push.tokenString ?? "",
                        "deviceId": application.uniqueIdentifier]
            for (key, value) in dict {
                request.setValue(String(describing: value), forHTTPHeaderField: key)
            }
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
    
}
