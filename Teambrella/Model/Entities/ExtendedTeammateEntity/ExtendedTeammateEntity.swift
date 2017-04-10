//
//  ExtendedTeammateEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ExtendedTeammateEntity: ExtendedTeammate {
    let id: String
    let ver: Int64
    
    var posts: [Post]?
    var couldVoteCount: Int?
    var coverageReduceInterval: Int?
    var coverageReduceTime: Int?
    var coverageReduceTimePrevious: Int?
    var dateCreated: Date?
    var dateJoined: Date?
    var dateUpdated: Date?
    var dateVotingFinished: Date?
    var isMyProxyVoter: Bool?
    var keywords: [String]?
    var maritalStatus: MaritalStatus?
    var maxPaymentLimitFiat: Int?
    var maxPaymentFiat: Int?
    
    var price: Int?
    var role: Int?
    var spayed: Int?
    var state: Int?
    var subType: Int?
    var topicID: String?
    var totallyPaidFiat: Double?
    var votedByProxyTimes: Int?
    var weight: Double?
    
    var description: String {
        return "ExtendedTeammateEntity \(id)"
    }
    
    init(json: JSON) {
        id = json["UserId"].stringValue
        ver = json["Ver"].int64Value
        
        price = json["Price"].int
        role = json["Role"].int
        spayed = json["Spayed"].int
        state = json["State"].int
        subType = json["SubType"].int
        topicID = json["TopicId"].string
        totallyPaidFiat = json["TotallyPaid_Fiat"].double
        votedByProxyTimes = json["VotedByProxyTimes"].int
        weight = json["Weight"].double
    }
}
