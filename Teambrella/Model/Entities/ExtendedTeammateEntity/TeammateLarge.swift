//
//  ExtendedTeammateEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.

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

class TeammateLarge {
    let id: String
    let teammateID: Int
    let ver: Int64
    
    let lastUpdated: Int64
    
    var topic: Topic
    var basic: TeammateBasicInfo
    var voting: TeammateVotingInfo?
    let object: CoveredObject
    let stats: TeammateStats
    let riskScale: RiskScaleEntity?
    var team: JSON
    
    // MARK: Team Part
    
    var coverageType: CoverageType { return CoverageType(rawValue: team["CoverageType"].intValue) ?? .other }
    var currency: String { return team["Currency"].stringValue }
    var teamAccessLevel: Int { return team["TeamAccessLevel"].intValue }

    var description: String {
        return "ExtendedTeammateEntity \(id)"
    }
    
    init(json: JSON) {
        team = json["TeamPart"]
        id = json["UserId"].stringValue
        teammateID = json["Id"].intValue
        ver = json["Ver"].int64Value
        lastUpdated = json["LastUpdated"].int64Value
        topic = TopicFactory.topic(with: json["DiscussionPart"])
        basic = TeammateBasicInfo(json: json["BasicPart"])
        voting = TeammateVotingInfo(json: json["VotingPart"])
        object = CoveredObject(json: json["ObjectPart"])
        stats = TeammateStats(json: json["StatsPart"])
        riskScale = RiskScaleEntity(json: json["RiskScalePart"])
    }
    
    func myProxy(set: Bool) {
        basic.isMyProxy = set
    }
    
    func update(votingResult: TeammateVotingResult) {
        topic.minutesSinceLastPost = votingResult.minutesSinceLast
        topic.unreadCount = votingResult.unreadCount
    }
    
}
