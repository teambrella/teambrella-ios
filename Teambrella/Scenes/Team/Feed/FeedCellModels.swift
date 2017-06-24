//
//  FeedCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum FeedCellType {
    case teammate, claim, topic
}

struct FeedCellModel {
    let title: String
    let text: String
    let avatar: String
    let teammatesAvatars: [String]
    let teammatesCount: Int
    let lastPostedMinutes: Int
    let unreadCount: Int
    let type: FeedCellType
    
    static var fake: FeedCellModel {
        return FeedCellModel(title: "Fake Discount Deals",
                                     text: "Just discovered a new garage in my neigborhood that is really good and...",
                                     avatar: "",
                                     teammatesAvatars: [],
                                     teammatesCount: 3,
                                     lastPostedMinutes: 1,
                                     unreadCount: 4,
                                     type: .teammate)
    }
}
