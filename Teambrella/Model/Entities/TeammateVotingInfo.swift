//
//  TeammateVotingInfo.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.

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

struct TeammateVotingInfo {
    let riskVoted: Double?
    let myVote: Double?
    //let proxyVote: Double?
    
    let proxyAvatar: String?
    let proxyName: String?
    
    let remainingMinutes: Int
    
    let votersCount: Int
    let votersAvatars: [String]
    
    init?(json: JSON) {
        guard json.dictionary != nil else { return nil }
        
        riskVoted = json["RiskVoted"].double
        myVote = json["MyVote"].double
        //proxyVote = json["ProxyVote"].double
        proxyAvatar = json["ProxyAvatar"].string
        proxyName = json["ProxyName"].string
        remainingMinutes = json["RemainedMinutes"].intValue
        votersCount = json["OtherCount"].intValue
        votersAvatars = json["OtherAvatars"].arrayObject as? [String] ?? []
    }
    
}
