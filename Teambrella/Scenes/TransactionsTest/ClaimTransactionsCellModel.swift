//
//  ClaimTransactionCellModel.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
/* Copyright(C) 2017  Teambrella, Inc.
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
//

import Foundation
import SwiftyJSON

struct ClaimTransactionsCellModel {
    let txID: String
    let userID: String
    let avatarString: String
    let name: String
    let amountCrypto: Double
    let amountFiat: Double
    let status: Int
    
    init(json: JSON) {
        txID = json["TxId"].stringValue
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        name = json["Name"].stringValue
        amountCrypto = json["AmountBtc"].doubleValue
        amountFiat = json["AmountFiat"].doubleValue
        status = json["Status"].intValue
    }
}
