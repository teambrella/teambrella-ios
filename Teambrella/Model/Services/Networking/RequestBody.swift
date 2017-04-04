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
    static func fakeRequestBody(with payload: [String: Any]?) -> RequestBody {
        let signature = "H1TpwvZo2nOgXg0XAk/HB30r3mBwnLqz9zGPHel87x1SKhMP6QmzEhDiuSe3uEhF6VXfLnJeliyUP3CtZrrEF5Y="
        let publicKey = "0203ca066905e668d1232a33bf5cce76ee1754b0a24ae9c28d20e13b069274742c"
        let timestamp: Int64 = 636262630000116200
        return RequestBody(timestamp: timestamp,
                           signature: signature,
                           publicKey: publicKey,
                           payload: payload)
    }
    
    static func fakeTeammatesBody() -> RequestBody {
        let payload: [String: Any] = ["TeamId": 1,
                                      "P": 0,
                                      "Search": NSNull()]
        let signature = "H+/Nxat2YJCxuQdWY2Sgf0Cn3I1K7u6lVABIxe5lSiEcFzuruOPv5oJ6AsNEfKusPB8ADEjBIdYgqZkA+hERQLU="
        let publicKey = "0203ca066905e668d1232a33bf5cce76ee1754b0a24ae9c28d20e13b069274742c"
        let tmpTimestamp: Int64 = 636263727164345142
        return RequestBody(timestamp: tmpTimestamp,
                           signature: signature,
                           publicKey: publicKey,
                           payload: payload)
    }

    static func teammatesBody(key: Key, teamID: Int = 1) -> RequestBody {
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
                                      "TeamId": 1,
                                      "AfterVer": 0]
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
