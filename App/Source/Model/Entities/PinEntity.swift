//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

struct PinEntity: Decodable {
    let type: ChatPinType
    let teamVote: Double
    let pinTitle: String
    let pinText: String
    let unpinTitle: String
    let unpinText: String
    
    static func teamPinType(from vote: Double) -> ChatPinType {
        switch vote {
        case ...(-0.501):
            return .unpinned
        case 0.501...:
            return .pinned
        default:
            return .unknown
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "MyPin"
        case teamVote = "TeamPin"
        case pinTitle = "PinTitle"
        case pinText = "PinText"
        case unpinTitle = "UnpinTitle"
        case unpinText = "UnpinText"
    }
}
