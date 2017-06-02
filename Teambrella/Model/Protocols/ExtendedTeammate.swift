//
//  ExtendedTeammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol ExtendedTeammate: EntityLike {
    var basic: TeammateBasicInfo { get }
    var topic: Topic { get set }
    var voting: TeammateVotingInfo? { get }
    var object: CoveredObject { get }
    var stats: TeammateStats { get }
}
