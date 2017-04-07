//
//  Teammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Teammate: EntityLike {
    // personal properties

    /// global user id
    var userID: String { get }
    /// user name
    var name: String { get }

    // group properties

    /// claim ceiling
    var claimLimit: Int { get }
    var claimsCount: Int { get }
    var isJoining: Bool { get }
    var isVoting: Bool { get }
    /// current risk index
    var risk: Double { get }
    var riskVoted: Double { get }
    var totallyPaid: Double { get }

    /// description of the object of insurance (dog type, or car model)
    var model: String { get }
    /// year of birth/manufacture of the object
    var year: Int { get }

    /// are there any unread messages from this user
    var hasUnread: Bool { get }

    // optional items

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
    var timestamp: TimeInterval? { get }
    var topicID: String? { get }
    var totallyPaidFiat: Double? { get }
    var votedByProxyTimes: Int? { get }
    var weight: Double? { get }

}
