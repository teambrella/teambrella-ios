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

struct PayToServerImpl: Codable {
    let isDefault: Bool
    let knownSince: String
    let teammateID: Int64
    let address: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case isDefault = "IsDefault"
        case knownSince = "KnownSince"
        case teammateID = "TeammateId"
        case address = "Address"
        case id = "Id"
    }

}
