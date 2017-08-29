//
//  PostEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.04.17.

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
import SwiftyJSON

struct PostEntity: Post {
    let id: String
    let lastUpdated: Int64
    
    let postContent: String
    let dateCreated: Date
    let upvotesCount: Int
    let downvotesCount: Int
    let myVote: Int
    let dateEdited: Date
    let isSolution: Bool
    let isTopicStarter: Bool
    let isSpam: Bool
    let ipAddress: String
    let isPending: Bool
    let userID: String
    
    var description: String {
        return "PostEntity id:\(id), \(postContent)"
    }
    
    init(json: JSON) {
        id = json["Id"].stringValue
        lastUpdated = json["Ver"].int64Value
        postContent = json["PostContent"].stringValue
        dateCreated = Date()//service.transformer.dateFromServer(string: json["DateCreated"].stringValue)
        upvotesCount = json["UpVoteCount"].intValue
        downvotesCount = json["DownVoteCount"].intValue
        myVote = json["MyVote"].intValue
        dateEdited = Date()//service.transformer.dateFromServer(string: json["DateEdited"].stringValue)
        isSolution = json["IsSolution"].boolValue
        isTopicStarter = json["IsTopicStarter"].boolValue
        isSpam = json["FlaggedAsSpam"].boolValue
        ipAddress = json["IpAddress"].stringValue
        isPending = json["Pending"].boolValue
        userID = json["UserId"].stringValue
    }

}

struct PostFactory {
    static func posts(with json: JSON) -> [Post]? {
        let posts = json.arrayValue
      //  guard let posts = json["Posts"].array else { return nil }

        return posts.map { PostEntity(json: $0) }
    }

    static func post(with json: JSON) -> Post? {
        return PostEntity(json: json)
    }

}
