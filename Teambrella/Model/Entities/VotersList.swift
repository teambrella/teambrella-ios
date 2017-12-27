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

struct VotersList {
    let me: Voter
    let median: Voter
    let voters: [Voter]
}

extension VotersList: Decodable {
    enum VotersListKeys: String, CodingKey {
        case me = "Me"
        case median = "Median"
        case voters = "Voters"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VotersListKeys.self)
        
        let me = try container.decode(Voter.self, forKey: .me)
        let median = try container.decode(Voter.self, forKey: .median)
        let voters = try container.decode([Voter].self, forKey: .voters)
        
        self.init(me: me, median: median, voters: voters)
    }
}
