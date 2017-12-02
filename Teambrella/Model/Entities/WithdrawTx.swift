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
    
    let serverTxState: Int
    
    init?(json: JSON) {
        guard let id = json["Id"].string,
            let lastUpdated = json["LastUpdated"].int64,
            let withdrawalID = json["WithdrawalId"].int,
            let serverTxState = json["ServerState"].int else { return nil }
        
        self.id = id
        self.lastUpdated = lastUpdated
        self.withdrawalID = withdrawalID
        self.serverTxState = serverTxState
        
        self.withdrawalDate = Formatter.teambrella.date(from: json["WithdrawalDate"].stringValue)
        self.isNew = json["IsNew"].boolValue
        
        let to = json["To"].arrayValue
        self.amount = to.first?["Amount"].doubleValue ?? 0
    }
    
    static func fake(state: Int) -> WithdrawTx? {
        let json = JSON([
            "WithdrawalId": 2025,
            "WithdrawalDate": "2017-12-01 13:05:38",
            "IsNew": false,
            "To": [ ["Amount": 0.0010] ],
            "ServerTxState": state,
            "Id": "9c315088-45d7-42d9-9737-a83c00d7c805",
            "LastUpdated": 636477303381343450
            ])
        return WithdrawTx(json: json)
    }
}
