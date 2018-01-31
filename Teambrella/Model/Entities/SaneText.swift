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

struct SaneText: Decodable {
    let original: String
    let sane: String

    static var empty: SaneText { return SaneText(text: "") }

    init(text: String) {
        original = text
        sane = SaneText.sanitized(text: text)
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        original = value
        sane = SaneText.sanitized(text: value)
    }

    private static func sanitized(text: String) -> String {
        let adapter = TextAdapter()
        return adapter.parsedHTML(string: text)
    }
    
}
