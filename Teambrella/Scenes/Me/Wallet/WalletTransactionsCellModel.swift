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
import SwiftyJSON

struct WalletTransactionsModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case claimID = "ClaimId"
        case lastUpdated = "LastUpdated"
        case serverTxState = "ServerTxState"
        case dateCreated = "DateCreated"
        case id = "Id"
        case to = "To"
    }

    let claimID: Int?
    let lastUpdated: Int
    let serverTxState: TransactionState
    let dateCreated: Date?
    let id: String
    let to: [WalletTransactionTo]
    
}

struct WalletTransactionsCellModelBuilder {
    func cellModels(from models: [WalletTransactionsModel]) -> [WalletTransactionsCellModel] {
        var result: [WalletTransactionsCellModel] = []
        for model in models {
            for subject in model.to {
                let detailsText = self.detailsText(claimID: model.claimID, transactionKind: subject.kind)
                let cellModel = WalletTransactionsCellModel(avatar: subject.avatar,
                                                            name: subject.name,
                                                            detailsText: detailsText,
                                                            amountText: self.amountText(amount: subject.amount),
                                                            kindText: self.typeText(state: model.serverTxState),
                                                            claimID: model.claimID)
                result.append(cellModel)
            }
        }
        return result
    }

    private func detailsText(claimID: Int?, transactionKind: TransactionKind) -> String {
        switch transactionKind {
        case .withdraw:
            return "Me.Wallet.Transactions.withdrawal".localized
        default:
            guard let claimID = claimID else { return "" }

            return "Me.Wallet.Transactions.claimNumber".localized(claimID)
        }
    }

    private func amountText(amount: Double) -> String {
        return String.formattedNumber(amount * 1000)
    }

    private func typeText(state: TransactionState) -> String {
        switch state {
        case .confirmed:
            return ""
            case .approvedAll,
                 .approvedCosigners,
                 .approvedMaster,
                 .beingCosigned,
                 .blockedCosigners,
                 .blockedMaster,
                 .cosigned,
                 .created,
                 .published,
                 .queued,
                 .selectedForCosigning:
            return "Me.Wallet.Transactions.kind.pending".localized
        default:
            return "Me.Wallet.Transactions.kind.cancelled".localized
        }
    }

}

struct WalletTransactionsCellModel {
    let avatar: String
    let name: String
    let detailsText: String
    let amountText: String
    let kindText: String

    let claimID: Int?

}

struct WalletTransactionTo: Decodable {
    enum CodingKeys: String, CodingKey {
        case kind = "Kind"
        case userID = "UserId"
        case name = "UserName"
        case amount = "Amount"
        case avatar = "Avatar"
    }

    let kind: TransactionKind
    let userID: String
    let name: String
    let amount: Double
    let avatar: String
}
