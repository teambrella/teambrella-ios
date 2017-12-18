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
import SwiftyJSON

struct WithdrawTx {
    let id: String
    let lastUpdated: Int64
    
    let withdrawalID: Int
    let withdrawalDate: Date?
    let isNew: Bool
    let amount: Double
    let toAddress: String
    
    let serverTxState: TransactionState
    
    init?(json: JSON) {
        guard let id = json["Id"].string,
            let lastUpdated = json["LastUpdated"].int64,
            let withdrawalID = json["WithdrawalId"].int,
            let serverTxState = json["ServerTxState"].int else { return nil }
        
        self.id = id
        self.lastUpdated = lastUpdated
        self.withdrawalID = withdrawalID
        self.serverTxState = TransactionState(rawValue: serverTxState) ?? .errorTechProblem
        
        self.withdrawalDate = Formatter.teambrella.date(from: json["WithdrawalDate"].stringValue)
        self.isNew = json["IsNew"].boolValue
        
        self.amount = json["Amount"].doubleValue
        self.toAddress = json["ToAddress"].stringValue
    }

}
