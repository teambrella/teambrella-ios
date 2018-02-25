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
 Avatar is a string address to the user avarar file located on server.
 It differs from photo and can't be used instead of it
 */
struct Avatar: Decodable {
    static var none: Avatar { return Avatar("") }
    
    let string: String

    init(_ string: String) {
        self.string = string
    }

    init(from decoder: Decoder) throws {
        string = try decoder.singleValueContainer().decode(String.self)
    }

}

extension Avatar {
    var urlString: String { return URLBuilder().avatarURLstring(for: string) }
    var url: URL? { return URL(string: urlString) }
}
