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
    var claimLimit: Int { get }
    var claimsCount: Int { get }
    var id: Int { get }
    var isJoining: Bool { get }
    var isVoting: Bool { get }
    var model: String { get }
    var name: String { get }
    var risk: Double { get }
    var riskVoted: Double { get }
    var totallyPaid: Double { get }
    var unread: Int { get }
    var userID: String { get }
    var ver: Int { get }
    var year: Int { get }
    
    init(json: JSON)
    
}
