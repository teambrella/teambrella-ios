//
//  Gender.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.06.17.

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

enum Gender: Codable {
    case male
    case female
    
    static func fromFacebook(string: String) -> Gender {
        return string == "female" ? .female : .male
    }
    
    /// fall back to male if received unsupported value
    static func fromServer(integer: Int) -> Gender {
        return integer == 2 ? .female : .male
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        let type = Gender.fromServer(integer: value)
        self = type
    }
    
    func encode(to encoder: Encoder) throws {
        let intValue = self == .male ? 1 : 2
        var container = encoder.singleValueContainer()
        try container.encode(intValue)
    }
    
}
