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

struct Voter {
    let userID: String
    let name: String
    let avatar: String
    let weight: Double
    let weightCombined: Double
    let proxyVoterID: String?
    let vote: Double
}

extension Voter: Decodable {
    enum VoterKeys: String, CodingKey {
        case userID = "UserId"
        case name = "Name"
        case avatar = "Avatar"
        case weight = "Weight"
        case weightCombined = "WeightCombined"
        case proxyVoterID = "VotedByProxyUserId"
        case vote = "Vote"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VoterKeys.self)
        
        let userID = try container.decode(String.self, forKey: .userID)
        let name = try container.decode(String.self, forKey: .name)
        let avatar = try container.decode(String.self, forKey: .avatar)
        let weight = try container.decode(Double.self, forKey: .weight)
        let weightCombined = try container.decode(Double.self, forKey: .weightCombined)
        let proxyVoterID = try container.decode(Optional<String>.self, forKey: .proxyVoterID)
        let vote = try container.decode(Double.self, forKey: .vote)
        
        self.init(userID: userID,
                  name: name,
                  avatar: avatar,
                  weight: weight,
                  weightCombined: weightCombined,
                  proxyVoterID: proxyVoterID,
                  vote: vote)
    }
}
