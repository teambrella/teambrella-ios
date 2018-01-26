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

struct TeamPart: Decodable {
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case coverageType = "CoverageType"
        case accessLevel = "TeamAccessLevel"
    }
    
    let coverageType: CoverageType
    let currency: String
    let accessLevel: TeamAccessLevel
    
    init() {
        coverageType = .other
        currency = ""
        accessLevel = .noAccess
    }
    
    init?(json: JSON) {
        guard !json.isEmpty else { return nil }
        
        coverageType = json["CoverageType"].int.flatMap { CoverageType(rawValue: $0) } ?? .other
        currency = json["Currency"].stringValue
        accessLevel = TeamAccessLevel(rawValue: json["TeamAccessLevel"].intValue) ?? .noAccess
    }
    
}
