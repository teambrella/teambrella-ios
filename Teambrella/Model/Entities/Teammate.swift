//
//  Teammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Teammate: CustomStringConvertible {
    // personal properties

    /// global user id
    var userID: String { get }
    /// user name
    var name: String { get }

    // group properties

    /// user id in this group
    var id: Int { get }
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
    /// entity version (every change of this entity on server increments this)
    var ver: Int { get }

    init(json: JSON)
}
