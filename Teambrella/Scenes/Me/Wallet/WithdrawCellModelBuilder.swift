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

class WithdrawModelBuilder {
    func detailsModel() -> WithdrawDetailsCellModel {
        return WithdrawDetailsCellModel()
    }
    
    func modelFrom(transaction: WithdrawTx) -> WithdrawTransactionCellModel {
        var dateText = ""
        if let date = transaction.withdrawalDate {
            dateText = Formatter.teambrella.string(from: date)
        }
        return WithdrawTransactionCellModel(topText: dateText,
                                            isNew: transaction.isNew,
                                            bottomText: "No address given".uppercased(),
                                            amountText: String.truncatedNumber(transaction.amount))
    }
    
}

protocol WithdrawCellModel {
    
}

class WithdrawDetailsCellModel: WithdrawCellModel {
    var title: String = "Me.Wallet.Withdraw.Details.title".localized
    var toText: String = "Me.Wallet.Withdraw.Details.to.title".localized
    var toValue: String = ""
    var amountText: String = "Me.Wallet.Withdraw.Details.amount.title".localized
    var amountValue: String = ""
    var buttonTitle: String = "Me.Wallet.Withdraw.Details.submitButton.title".localized

}

struct WithdrawTransactionCellModel: WithdrawCellModel {
    let topText: String
    let isNew: Bool
    let bottomText: String
    let amountText: String
}

struct WithdrawCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: WithdrawCellModel) {
        if let cell = cell as? WithdrawDetailsCell, let model = model as? WithdrawDetailsCellModel {
            cell.titleLabel.text = model.title
            cell.toLabel.text = model.toText
            //cell.placeholder.text = ""
            cell.cryptoAddressTextView.text = model.toValue
            cell.qrButton.setImage(#imageLiteral(resourceName: "qrCode"), for: .normal) //
            cell.amountLabel.text = model.amountText
            cell.cryptoAmountTextField.text = model.amountValue
            cell.submitButton.setTitle(model.buttonTitle, for: .normal)
        } else if let cell = cell as? WithdrawCell, let model = model as? WithdrawTransactionCellModel {
            cell.upperLabel.text = model.topText
            cell.lowerLabel.text = model.bottomText
            cell.indicatorView.isHidden = !model.isNew
            cell.rightLabel.text = model.amountText
        }
    }
}
