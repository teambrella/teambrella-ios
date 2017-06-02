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
    let ver: Int64
    
    let originalPostText: String
    let topPosterAvatars: [String]
    let posterCount: Int
    let unreadCount: Int
    let minutesSinceLastPost: Int
    
    var posts: [Post]
    
    var description: String {
        return "TopicEntity id: \(id); posts: \(posts.count)"
    }
    
    init(json: JSON) {
        id = json["TopicId"].stringValue
        ver = json["Ver"].int64Value
        
        originalPostText = json["OriginalPostText"].stringValue
        topPosterAvatars = json["TopPosterAvatars"].arrayObject as? [String] ?? []
        posterCount = json["PosterCount"].intValue
        unreadCount = json["UnreadCount"].intValue
        minutesSinceLastPost = json["SinceLastPostMinutes"].intValue
        
        posts = PostFactory.posts(with: json["Posts"]) ?? []
    }
}

struct TopicFactory {
    static func topic(with json: JSON) -> Topic {
        return TopicEntity(json: json)
    }
}
