//
/* Copyright(C) 2017 Teambrella, Inc.
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

struct WithdrawTx: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case lastUpdated = "LastUpdated"
        case withdrawalID = "WithdrawalId"
        case serverTxState = "ServerTxState"
        case withdrawalDate = "WithdrawalDate"
        case isNew = "IsNew"
        case amount = "Amount"
        case toAddress = "ToAddress"
    }
    
    let id: String
    let lastUpdated: Int64
    
    let withdrawalID: Int
    let withdrawalDate: Date?
    let isNew: Bool
    let amount: Ether
    let toAddress: String
    
    let serverTxState: TransactionState
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.lastUpdated = try container.decode(Int64.self, forKey: .lastUpdated)
        self.withdrawalID = try container.decode(Int.self, forKey: .withdrawalID)
        let rawState = try container.decode(Int.self, forKey: .serverTxState)
        self.serverTxState = TransactionState(rawValue: rawState) ?? .errorTechProblem
        let dateString = try container.decode(String.self, forKey: .withdrawalDate)
        guard let date = Formatter.teambrella.date(from: dateString) else {
            throw TeambrellaErrorFactory.malformedDate(format: dateString)
        }
        
        self.withdrawalDate = date
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.amount = try container.decode(Ether.self, forKey: .amount)
        self.toAddress = try container.decode(String.self, forKey: .toAddress)
    }
    
}
