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

struct Year: Decodable, CustomStringConvertible {
    struct Constant {
        // astronomic year
        static let secondsInYear: TimeInterval = 31_557_600.0
    }
    static var empty: Year { return Year(0) }

    let value: Int
    var description: String { return "\(value)" }

    var yearsSinceNow: Int {
        let yearsSince1970 = value - 1970
        let date = Date(timeIntervalSince1970: Constant.secondsInYear * Double(yearsSince1970))
        return -Int(date.timeIntervalSinceNow / Constant.secondsInYear)
    }

    init(_ value: Int) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        value = try decoder.singleValueContainer().decode(Int.self)
    }

}
