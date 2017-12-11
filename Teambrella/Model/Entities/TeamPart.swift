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

protocol TeamPart {
    var coverage: CoverageType? { get }
    var currency: String { get }
    var accessLevel: TeamAccessLevel { get }
}

struct TeamPartConcrete: TeamPart {
    let coverage: CoverageType?
    let currency: String
    let accessLevel: TeamAccessLevel
    
    init(json: JSON) {
        coverage = json["CoverageType"].int.flatMap { CoverageType(rawValue: $0) }
        currency = json["Currency"].stringValue
        accessLevel = TeamAccessLevel(rawValue: json["TeamAccessLevel"].intValue) ?? .noAccess
    }
    
}

struct TeamPartFactory {
    static func teamPart(from json: JSON) -> TeamPart? {
        var json = json
        if json["TeamPart"].exists() { json = json["TeamPart"] }
        
        return TeamPartConcrete(json: json)
    }
    
}
