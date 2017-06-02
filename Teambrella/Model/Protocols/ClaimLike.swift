//
//  ClaimLike.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol ClaimLike: EntityLike {
    var smallPhoto: String { get }
    var avatar: String { get }
    var model: String { get }
    var name: String { get }
    var state: ClaimState { get }
    var claimAmount: Double { get }
    var reimbursement: Double { get }
    var votingResBTC: Double { get }
    var paymentResBTC: Double { get }
    
    var proxyAvatar: String? { get }
    var proxyName: String? { get }
    
}
