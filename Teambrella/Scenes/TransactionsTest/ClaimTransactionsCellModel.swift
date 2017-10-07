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
    let userID: String
    let avatarString: String
    let name: String
    let status: TransactionState
    let to: [ClaimTransactionTo]
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        name = json["Name"].stringValue
        status = TransactionState(rawValue: json["Status"].intValue) ?? .created
        to = json["To"].arrayValue.flatMap { ClaimTransactionTo(json: $0) }
    }
}

struct ClaimTransactionTo {
    let amountCrypto: Double
    let userID: String
    let name: String
    let avatarString: String
    let amountFiat: Double
    
    init(json: JSON) {
        amountCrypto = json["AmountCrypto"].doubleValue
        userID = json["UserId"].stringValue
        name = json["Name"].stringValue
        avatarString = json["Avatar"].stringValue
        amountFiat = json["AmountFiat"].doubleValue
    }
}
