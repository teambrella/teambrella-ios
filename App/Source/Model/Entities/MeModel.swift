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

/// Short model of my user
struct MeModel: Decodable {
    let id: String
    let name: Name
    let fbName: String?
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case fbName = "FBName"
        case avatar = "Avatar"
    }

}
