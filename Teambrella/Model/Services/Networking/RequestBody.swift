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
        return RequestBody(payload: payload,
                           timestamp: timestamp,
                           signature: signature,
                           publicKey: publicKey)
    }
    
    static func fakeTeammatesBody() -> RequestBody {
        let payload: [String: Any] = ["TeamId": 1]
        let signature = "H+/Nxat2YJCxuQdWY2Sgf0Cn3I1K7u6lVABIxe5lSiEcFzuruOPv5oJ6AsNEfKusPB8ADEjBIdYgqZkA+hERQLU="
        let publicKey = "0203ca066905e668d1232a33bf5cce76ee1754b0a24ae9c28d20e13b069274742c"
        let timestamp: Int64 = 636263727164345142
        return RequestBody(payload: payload,
                           timestamp: timestamp,
                           signature: signature,
                           publicKey: publicKey)
    }
    
}

struct RequestBody {
    var payload: [String: Any]?
    let timestamp: Int64
    let signature: String
    let publicKey: String
    
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
