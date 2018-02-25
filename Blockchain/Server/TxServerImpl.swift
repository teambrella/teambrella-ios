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

struct TxServerImpl: Codable {
    let claimID: Int64?
    let teammateID: Int64
    let initiatedTime: String
    let state: Int16
    let kind: Int16
    let withdrawReqID: Int64? // ???????
    let amountCrypto: Decimal
    let moveToMultisigID: Int64?
    let claimTeammateID: Int64?
    let id: String

    enum CodingKeys: String, CodingKey {
        case claimID = "ClaimId"
        case teammateID = "TeammateId"
        case initiatedTime = "InitiatedTime"
        case state = "State"
        case kind = "Kind"
        case withdrawReqID = "WithdrawReqId"
        case amountCrypto = "AmountCrypto"
        case moveToMultisigID = "MoveToMultisigId"
        case claimTeammateID = "ClaimTeammateId"
        case id = "Id"
    }
    
}
