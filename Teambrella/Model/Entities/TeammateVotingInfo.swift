//
//  TeammateVotingInfo.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TeammateVotingInfo {
    let riskVoted: Double?
    let myVote: Double?
    let proxyVote: Double?
    
    let proxyAvatar: String?
    let proxyName: String?
    
    let remainingMinutes: Int
    
    let votersCount: Int
    let votersAvatars: [String]
    
    init?(json: JSON) {
        guard json.dictionary != nil else { return nil }
        
        riskVoted = json["RiskVoted"].double
        myVote = json["MyVote"].double
        proxyVote = json["ProxyVote"].double
        proxyAvatar = json["ProxyAvatar"].string
        proxyName = json["ProxyName"].string
        remainingMinutes = json["RemainedMinutes"].intValue
        votersCount = json["OtherCount"].intValue
        votersAvatars = json["OtherAvatars"].arrayObject as? [String] ?? []
    }
    
}
