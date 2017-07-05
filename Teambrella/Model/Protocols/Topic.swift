//
//  Topic.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol Topic: EntityLike {
    var originalPostText: String { get }
    var topPosterAvatars: [String] { get }
    var posterCount: Int { get }
    var unreadCount: Int { get set }
    var minutesSinceLastPost: Int { get set }
    
    var posts: [Post] { get set }
}
