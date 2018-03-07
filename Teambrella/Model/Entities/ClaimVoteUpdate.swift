//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct ClaimVoteUpdate: Decodable, CustomStringConvertible {
    let id: Int
    let lastUpdated: Int64
    let voting: ClaimEntityLarge.VotingPart
    let discussion: ClaimVoteUpdate.DiscussionPartUpdate

    var description: String { return "\(type(of: self)) id: \(id)" }
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case lastUpdated = "LastUpdated"
        case voting = "VotingPart"
        case discussion = "DiscussionPart"
    }

    struct DiscussionPartUpdate: Decodable {
        let unreadCount: Int
        let minutesSinceLastPost: Int

        enum CodingKeys: String, CodingKey {
            case unreadCount = "UnreadCount"
            case minutesSinceLastPost = "SinceLastPostMinutes"
        }

    }

}
