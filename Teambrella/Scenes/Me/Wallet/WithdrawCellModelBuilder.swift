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
    func infoModel(amount: Double, reserved: Double, available: Double, currencyRate: Double) -> WalletInfoCellModel {
        return WalletInfoCellModel(amount: amount, reserved: reserved, available: available, currencyRate: currencyRate)
    }

    func detailsModel(maxAmount: Double) -> WithdrawDetailsCellModel {
        return WithdrawDetailsCellModel(amountPlaceholder: "Max \(String.truncatedNumber(maxAmount)) mETH")
    }
    
    func modelFrom(transaction: WithdrawTx) -> WithdrawTransactionCellModel {
        var dateText = ""
        if let date = transaction.withdrawalDate {
            dateText = Formatter.teambrellaShort.string(from: date)
        }
        return WithdrawTransactionCellModel(topText: dateText,
                                            isNew: transaction.isNew,
                                            bottomText: transaction.toAddress,
                                            amountText: String(format: "%.2f", transaction.amount * 1000))
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
    var amountPlaceholder: String
    
    init(amountPlaceholder: String) {
        self.amountPlaceholder = amountPlaceholder
    }
}

struct WithdrawTransactionCellModel: WithdrawCellModel {
    let topText: String
    let isNew: Bool
    let bottomText: String
    let amountText: String
}

struct WalletInfoCellModel: WithdrawCellModel {
    let amount: Double
    let reserved: Double
    let available: Double
    let currencyRate: Double
    
}

struct WithdrawCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: WithdrawCellModel) {
        if let cell = cell as? WithdrawDetailsCell, let model = model as? WithdrawDetailsCellModel {
            cell.titleLabel.text = model.title
            cell.toLabel.text = model.toText
            cell.placeholder.isHidden = model.toValue != ""
            cell.cryptoAddressTextView.text = model.toValue
            cell.qrButton.setImage(#imageLiteral(resourceName: "qrCode"), for: .normal)
            cell.amountLabel.text = model.amountText
            cell.cryptoAmountTextField.placeholder = model.amountPlaceholder
            cell.cryptoAmountTextField.text = model.amountValue
            cell.submitButton.setTitle(model.buttonTitle, for: .normal)
            
            //            cell.cryptoAmountTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            //            cell.cryptoAmountTextField.text = model.amountValue
            //            cell.cryptoAmountTextField.tintColor = cell.textField.tintColor.withAlphaComponent(1)
            //            // cell.cryptoAmountTextField.tag = indexPath.row
            //            cell.cryptoAmountTextField.removeTarget(reportVC, action: nil, for: .allEvents)
            //            cell.cryptoAmountTextField.addTarget(delegate, action: #selector(ReportVC.textFieldDidChange),
            //                                                 for: .editingChanged)
            //            cell.cryptoAddressTextView.text = model.toValue
            //            // cell.cryptoAddressTextView.tag = indexPath.row
            //            cell.cryptoAddressTextView.delegate = delegate
            //            cell.cryptoAddressTextView.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            
        } else if let cell = cell as? WithdrawCell, let model = model as? WithdrawTransactionCellModel {
            cell.upperLabel.text = model.topText
            cell.lowerLabel.text = model.bottomText
            cell.indicatorView.isHidden = !model.isNew
            cell.rightLabel.text = model.amountText
        } else if let cell = cell as? WalletInfoCell, let model = model as? WalletInfoCellModel {
            populateWalletInfo(cell: cell, model: model)
        }
    }
    
    private static func populateWalletInfo(cell: WalletInfoCell, model: WalletInfoCellModel) {
        cell.numberBar.isBottomLineVisible = false
        cell.amount.text = String.formattedNumber(model.amount * 1000)
        
        cell.currencyLabel.text = service.session?.cryptoCoin.code
        if let team = service.session?.currentTeam {
            cell.auxillaryAmount.text = String.formattedNumber(model.amount * model.currencyRate) + " " + team.currency
        }
        
        cell.numberBar.left?.titleLabel.text = "Me.WalletVC.leftBrick.title".localized
        cell.numberBar.left?.amountLabel.text = model.reserved < 0.1
            ? String.formattedNumber(model.reserved * 1000)
            : String.truncatedNumber(model.reserved * 1000)
        cell.numberBar.left?.isBadgeVisible = false
        cell.numberBar.left?.currencyLabel.text = service.session?.cryptoCoin.code
        
        cell.numberBar.right?.titleLabel.text = "Me.WalletVC.rightBrick.title".localized
        cell.numberBar.right?.amountLabel.text = model.available < 0.1
            ? String.formattedNumber(model.available * 1000)
            : String.truncatedNumber(model.available * 1000)
        cell.numberBar.right?.currencyLabel.text = service.session?.cryptoCoin.code
    }
}
