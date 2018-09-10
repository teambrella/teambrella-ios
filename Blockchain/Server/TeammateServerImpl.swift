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

struct TeammateServerImpl: Codable {
    let cryptoAddress: String?
    let fbName: String?
    let publicKey: String?
    let teamID: Int64
    let name: String
    let id: Int64
    let socialName: String?

    enum CodingKeys: String, CodingKey {
        case cryptoAddress = "CryptoAddress"
        case fbName = "FBName"
        case publicKey = "PublicKey"
        case teamID = "TeamId"
        case name = "Name"
        case id = "Id"
        case socialName = "SocialName"
    }

}
