//
/* Copyright(C) 2017 Teambrella, Inc.
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

protocol VotingPart {
    var remainingMinutes: Int { get }
    var proxyName: String? { get }
    var proxyAvatar: String? { get }
    var myVote: Double? { get }
    
    init(json: JSON)
}

struct VotingPartClaimConcrete: VotingPart {
    let remainingMinutes: Int
    let proxyName: String?
    let proxyAvatar: String?
    let myVote: Double?
    
    let ratioVoted: Double?
    let otherCount: Int
    let otherAvatars: [String]
    
    init(json: JSON) {
       remainingMinutes = json["RemainedMinutes"].intValue
        proxyName = json["ProxyName"].string
        proxyAvatar = json["ProxyAvatar"].string
        myVote = json["MyVote"].double
        
        ratioVoted = json["RatioVoted"].double
        otherCount = json["OtherCount"].intValue
        otherAvatars = json["OtherAvatars"].arrayObject as? [String] ?? []
    }
    
}

struct VotingPartTeammateConcrete: VotingPart {
    let remainingMinutes: Int
    let proxyName: String?
    let proxyAvatar: String?
    let myVote: Double?
    
    let riskVoted: Double?
    
    init(json: JSON) {
        remainingMinutes = json["RemainedMinutes"].intValue
        proxyName = json["ProxyName"].string
        proxyAvatar = json["ProxyAvatar"].string
        myVote = json["MyVote"].double
        
        riskVoted = json["RiskVoted"].double
    }
    
}

struct VotingPartFactory {
    static func votingPart(from json: JSON) -> VotingPart? {
        var json = json
        if json["VotingPart"].exists() { json = json["VotingPart"] }
        
        if json["RatioVoted"].exists() {
            return VotingPartClaimConcrete(json: json)
        } else if json["RiskVoted"].exists() {
            return VotingPartTeammateConcrete(json: json)
        } else {
            return nil
        }
    }
    
}
