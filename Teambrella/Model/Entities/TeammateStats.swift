//
//  TeammateStats.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TeammateStats {
    let weight: Double
    let proxyRank: Double
    let decisionFrequency: Double
    let discussionFrequency: Double
    let votingFrequency: Double
    
    init(json: JSON) {
        weight = json["Weight"].doubleValue
        proxyRank = json["ProxyRank"].doubleValue
        decisionFrequency = json["DecisionFreq"].doubleValue
        discussionFrequency = json["DiscussionFreq"].doubleValue
        votingFrequency = json["VotingFreq"].doubleValue
    }
    
}
