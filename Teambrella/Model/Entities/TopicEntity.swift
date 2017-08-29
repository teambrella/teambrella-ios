//
//  TopicEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.04.17.

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

struct TopicEntity: Topic {
    let id: String
    let lastUpdated: Int64
    
    let originalPostText: String
    let topPosterAvatars: [String]
    let posterCount: Int
    var unreadCount: Int
    var minutesSinceLastPost: Int
    
    var posts: [Post]
    
    var description: String {
        return "TopicEntity id: \(id); posts: \(posts.count)"
    }
    
    init(json: JSON) {
        id = json["TopicId"].stringValue
        lastUpdated = json["LastUpdated"].int64Value
        
        originalPostText = json["OriginalPostText"].stringValue
        topPosterAvatars = json["TopPosterAvatars"].arrayObject as? [String] ?? []
        posterCount = json["PosterCount"].intValue
        unreadCount = json["UnreadCount"].intValue
        minutesSinceLastPost = json["SinceLastPostMinutes"].intValue
        
        posts = PostFactory.posts(with: json["Posts"]) ?? []
    }
    
    init(id: String) {
        self.id = id
        lastUpdated = 0
        originalPostText = ""
        topPosterAvatars = []
        posterCount = 0
        unreadCount = 0
        minutesSinceLastPost = 0
        posts = []
    }
}

struct TopicFactory {
    static func topic(with json: JSON) -> Topic {
        return TopicEntity(json: json)
    }
}
