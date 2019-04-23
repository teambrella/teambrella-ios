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

struct TransactionsCellModelBuilder {
    func cellModels(from models: [WalletTransactionsModel]) -> [WalletTransactionsCellModel] {
        var result: [WalletTransactionsCellModel] = []
        for model in models {
            for subject in model.to ?? [] {
                let detailsText = self.detailsText(claimID: model.claimID, transactionKind: subject.kind)
                let cellModel = WalletTransactionsCellModel(avatar: subject.avatar,
                                                            smallPhoto: model.smallPhoto,
                                                            name: (model.claimID == nil) ? subject.name.entire : "\(model.modelOrName ?? ""), \(model.year ?? 0)",
                                                            detailsText: detailsText,
                                                            amountFiat: subject.amountFiat,
                                                            amountCrypto: subject.amount,
                                                            amountFiatMonth: model.amountFiatMonth,
                                                            amountFiatYear: model.amountFiatYear,
                                                            amountText: "",
                                                            kindText: self.typeText(state: model.serverTxState),
                                                            month: (model.dateCreated?.month ?? 0) + (model.dateCreated?.year ?? 0) * 12,
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
                                                            smallPhoto: nil,
                                                            name: model.name.entire,
                                                            detailsText: detailsText,
                                                            amountFiat: subject.amountFiat,
                                                            amountCrypto: subject.amount,
                                                            amountFiatMonth: Fiat(0),
                                                            amountFiatYear: Fiat(0),
                                                            amountText: self.amountText(amount: subject.amount),
                                                            kindText: self.typeText(state: model.status),
                                                            month: 0,
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
        return String(format: "%.2f", MEth(amount).value)
        //return String.formattedNumber(MEth(amount).value)
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
