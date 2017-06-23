//
//  FeedCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol FeedCellModel {
    
}

struct FeedTeammateCellModel: FeedCellModel {
    let title: String
    let text: String
    let avatar: String
    let teammatesAvatars: [String]
    let teammatesCount: Int
    let lastPostedMinutes: Int
    let repliesCount: Int
    
    static var fake: FeedTeammateCellModel {
        return FeedTeammateCellModel(title: "Fake Discount Deals",
                                     text: "Just discovered a new garage in my neigborhood that is really good and...",
                                     avatar: "",
                                     teammatesAvatars: [],
                                     teammatesCount: 3,
                                     lastPostedMinutes: 1,
                                     repliesCount: 4)
    }
}

struct FeedClaimCellModel: FeedCellModel {
    
}

struct FeedTopicCellModel: FeedCellModel {
    
}
