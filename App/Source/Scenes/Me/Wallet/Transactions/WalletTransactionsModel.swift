//
//  WalletTransactionsCellModel.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 02.09.17.
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

struct WalletTransactionsModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case claimID = "ClaimId"
        case lastUpdated = "LastUpdated"
        case serverTxState = "ServerTxState"
        case dateCreated = "DateCreated"
        case amountFiatMonth = "AmountFiatMonth"
        case amountFiatYear = "AmountFiatYear"
        case modelOrName = "ModelOrName"
        case smallPhoto = "SmallPhoto"
        case year = "Year"
        case id = "Id"
        case to = "To"
    }

    struct TransactionTo: Decodable {
        enum CodingKeys: String, CodingKey {
            case kind = "Kind"
            case userID = "UserId"
            case name = "UserName"
            case amount = "Amount"
            case amountFiat = "AmountFiat"
            case avatar = "Avatar"
        }

        let kind: TransactionKind
        let userID: String
        let name: Name
        let amount: Ether
        let amountFiat: Fiat
        let avatar: Avatar
    }

    let claimID: Int?
    let lastUpdated: Int64
    let serverTxState: TransactionState
    let dateCreated: Date?
    let amountFiatMonth: Fiat
    let amountFiatYear: Fiat
    let id: String
    let to: [TransactionTo]?
    let modelOrName: String?
    let year: Int?
    let smallPhoto: String?
}
