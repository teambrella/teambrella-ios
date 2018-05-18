//
//  RequestBody.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.

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

struct RequestBodyFactory {
    static func teammatesBody(key: Key, teamID: Int = service.session?.currentTeam?.teamID ?? 0) -> RequestBody {
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
                                      "TeamId": service.session?.currentTeam?.teamID ?? 0,
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
    var contentType: String?
    var data: Data?
    
    init(timestamp: Int64, signature: String, publicKey: String, payload: [String: Any]?) {
        self.payload = payload
        self.timestamp = timestamp
        self.signature = signature
        self.publicKey = publicKey
    }
    
    init(key: Key, payload: [String: Any]? = nil) {
        let key = key
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
        return result
    }

}
