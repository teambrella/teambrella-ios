//
//  TeammateLike.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation
import SwiftyJSON

protocol TeammateLike: EntityLike {
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
    
    /// url string to get avatar image from
    var avatar: String { get }
    
    /// entire model is loaded
    var isComplete: Bool { get }

    // optional items

    var extended: ExtendedTeammate? { get set }
    
    mutating func updateWithVote(json: JSON)
}
