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

struct MultisigServerImpl: Codable {
    let status: Int32
    let propertyChanged: String
    let teammateID: Int64
    let address: String?
    let ver: Int
    let dateCreated: String
    let id: Int64

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case propertyChanged = "PropertyChanged"
        case teammateID = "TeammateId"
        case address = "Address"
        case ver = "Ver"
        case dateCreated = "DateCreated"
        case id = "Id"
    }
    
}
