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

struct ClaimVote: Decodable {
    let value: Double
    
    var percentage: Double { return value * 100 }
    var integerPercentage: Int { return Int(percentage + 0.5) }

    init(_ value: Double) {
        self.value = value
    }

    init(_ value: Float) {
        self.value = Double(value)
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Double.self)
        self.value = value
    }

    func fiat(from fiat: Fiat) -> Fiat {
        return Fiat(value * fiat.value)
    }

}
