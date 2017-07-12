//
//  TopicEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
