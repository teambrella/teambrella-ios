//
//  ExtendedTeammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol ExtendedTeammate: EntityLike {
    var posts: [Post]? { get }
    var couldVoteCount: Int? { get }
    var coverageReduceInterval: Int? { get }
    var coverageReduceTime: Int? { get }
    var coverageReduceTimePrevious: Int? { get }
    var dateCreated: Date? { get }
    var dateJoined: Date? { get }
    var dateUpdated: Date? { get }
    var dateVotingFinished: Date? { get }
    var isMyProxyVoter: Bool? { get }
    var keywords: [String]? { get }
    var maritalStatus: MaritalStatus? { get }
    var maxPaymentLimitFiat: Int? { get }
    var maxPaymentFiat: Int? { get }
    
    var price: Int? { get }
    var role: Int? { get }
    var spayed: Int? { get }
    var state: Int? { get }
    var subType: Int? { get }
    var topicID: String? { get }
    var totallyPaidFiat: Double? { get }
    var votedByProxyTimes: Int? { get }
    var weight: Double? { get }
}
