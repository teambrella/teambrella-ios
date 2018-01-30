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

struct WalletTransactionsCellModel {
    let avatar: String
    let name: String
    let detailsText: String
    let amountText: String
    let kindText: String

    let claimID: Int?
    let userID: String?

}

struct TransactionsCellModelBuilder {
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
                                                            claimID: model.claimID,
                                                            userID: nil)
                result.append(cellModel)
            }
        }
        return result
    }

    func cellModels(from models: [ClaimTransactionsModel]) -> [WalletTransactionsCellModel] {
        var result: [WalletTransactionsCellModel] = []
        for model in models {
            for subject in model.to {
                let detailsText = ""
                let cellModel = WalletTransactionsCellModel(avatar: model.avatar,
                                                            name: model.name,
                                                            detailsText: detailsText,
                                                            amountText: self.amountText(amount: subject.amount),
                                                            kindText: self.typeText(state: model.status),
                                                            claimID: nil,
                                                            userID: model.userID)
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

    private func amountText(amount: Ether) -> String {
        return String.formattedNumber(MEth(amount).value)
    }

    private func typeText(state: TransactionState?) -> String {
        guard let state = state else { return "" }
        
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
