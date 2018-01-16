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

struct ClaimTransactionsCellModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case avatarString = "Avatar"
        case name = "Name"
        case status = "Status"
        case to = "To"
    }
    
    let userID: String
    let avatarString: String
    let name: String
    let status: TransactionState
    let to: [ClaimTransactionTo]
    
}

struct ClaimTransactionTo: Decodable {
    enum CodingKeys: String, CodingKey {
        case amountCrypto = "AmountCrypto"
        case userID = "UserId"
        case name = "Name"
        case avatarString = "Avatar"
        case amountFiat = "AmountFiat"
    }
    
    let amountCrypto: Double
    let userID: String
    let name: String
    let avatarString: String
    let amountFiat: Double
    
}
