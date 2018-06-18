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

/**
 Coverage is a coefficient that is applied to the claim amount to calculate actual amount to be paid
 */
struct Coverage: Decodable {
    let value: Double
    var percentage: Double { return value * 100 }
    var integerPercentage: Int { return Int(percentage + 0.5) }

    static var no: Coverage { return Coverage(0) }

    func ethers(from: Ether) -> Ether {
        return Ether(from.value * value)
    }

    init(_ value: Double) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Double.self)
        self.value = value
    }
    
}
