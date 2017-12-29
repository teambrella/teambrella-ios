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

/**
 Is used for parsing server reply after user changes his vote
 */
struct TeammateVotingResult: Decodable {
    enum CodingKeys: String, CodingKey {
        case discussion = "DiscussionPart"
        case id = "Id"
        case lastUpdated = "LastUpdated"
        case voting = "VotingPart"
    }
    
    enum DiscussionKeys: String, CodingKey {
        case minutesSinceLast = "SinceLastPostMinutes"
        case unreadCount = "UnreadCount"
    }
    
    enum VotingKeys: String, CodingKey {
        case myVote = "MyVote"
        case otherAvatars = "OtherAvatars"
        case otherCount = "OtherCount"
        case proxyAvatar = "ProxyAvatar"
        case proxyName = "ProxyName"
        case minutesRemaining = "RemainedMinutes"
        case riskVoted = "RiskVoted"
    }
    
    let id: Int
    let lastUpdated: Int64
    
    let unreadCount: Int
    let minutesSinceLast: Int
    
    let myVote: Double?
    let otherAvatars: [String]
    let otherCount: Int
    let proxyAvatar: String?
    let proxyName: String?
    let minutesRemaining: Int?
    let riskVoted: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        lastUpdated = try container.decode(Int64.self, forKey: .lastUpdated)
        
        let discussion = try container.nestedContainer(keyedBy: DiscussionKeys.self, forKey: .discussion)
        unreadCount = try discussion.decode(Int.self, forKey: .unreadCount)
        minutesSinceLast = try discussion.decode(Int.self, forKey: .minutesSinceLast)
        
        let voting = try container.nestedContainer(keyedBy: VotingKeys.self, forKey: .voting)
        myVote = try voting.decodeIfPresent(Double.self, forKey: .myVote)
        otherAvatars = try voting.decode([String].self, forKey: .otherAvatars)
        otherCount = try voting.decode(Int.self, forKey: .otherCount)
        proxyAvatar = try voting.decodeIfPresent(String.self, forKey: .proxyAvatar)
        proxyName = try voting.decodeIfPresent(String.self, forKey: .proxyName)
        minutesRemaining = try voting.decodeIfPresent(Int.self, forKey: .minutesRemaining)
        riskVoted = try voting.decodeIfPresent(Double.self, forKey: .riskVoted)
    }
}
