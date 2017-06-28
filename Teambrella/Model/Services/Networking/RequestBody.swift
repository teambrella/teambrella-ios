//
//  RequestBody.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct RequestBodyFactory {
    static func teammatesBody(key: Key, teamID: Int = ServerService.teamID) -> RequestBody {
        let payload: [String: Any] = ["TeamId": teamID,
                                      "P": 0,
                                      "Search": NSNull()]
        return RequestBody(timestamp: key.timestamp,
                signature: key.signature,
                publicKey: key.publicKey,
                payload: payload)
    }
    
    static func teammateBody(key: Key, id: String) -> RequestBody? {
        let payload: [String: Any] = ["UserId": id,
                                      "TeamId": ServerService.teamID,
                                      "AfterVer": 0]
        return RequestBody(key: key, payload: payload)
    }

    static func newPostBody(key: Key, topicID: String, text: String) -> RequestBody? {
        let payload: [String: Any] = ["TopicId": topicID,
        "Text": text]
        return RequestBody(key: key, payload: payload)
    }
    
}

struct RequestBody {
    var payload: [String: Any]?
    let timestamp: Int64
    let signature: String
    let publicKey: String
    
    init(timestamp: Int64, signature: String, publicKey: String, payload: [String: Any]?) {
        self.payload = payload
        self.timestamp = timestamp
        self.signature = signature
        self.publicKey = publicKey
    }
    
    init(key: Key, payload: [String: Any]? = nil) {
        self.payload = payload
        self.timestamp = key.timestamp
        self.signature = key.signature
        self.publicKey = key.publicKey
    }
    
    var dictionary: [String: Any] {
        var result: [String: Any] = [:]
        if let payload = payload {
            for (key, value) in payload {
                result[key] = value
            }
        }
        result["Timestamp"] = timestamp
        result["Signature"] = signature
        result["PublicKey"] = publicKey
        return result
    }
    
    var json: JSON {
        return JSON(dictionary)
    }
}
