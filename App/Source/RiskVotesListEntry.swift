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

struct RiskVotesListEntry: Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case name = "Name"
        case avatar = "Avatar"
        case model = "Model"
        case year = "Year"
        case proxyVoterID = "VotedByProxyUserId"
        case vote = "Vote"
        case teamVote = "TeamVote"
    }
    
    let userID: String
    let name: Name
    let avatar: Avatar
    let model: String
    let year: Year
    let proxyVoterID: String?
    let vote: Double?
    let teamVote: Double?
}
