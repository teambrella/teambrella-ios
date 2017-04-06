//
//  Post.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol Post: EntityLike {
    var postContent: String { get }
    var dateCreated: Date { get }
    var upvotesCount: Int { get }
    var downvotesCount: Int { get }
    var myVote: Int { get }
    var dateEdited: Date { get }
    var isSolution: Bool { get }
    var isTopicStarter: Bool { get }
    var hasSpamFlag: Bool { get }
    var ipAddress: String { get }
    var isPending: Bool { get }
    var userID: String { get }

}
