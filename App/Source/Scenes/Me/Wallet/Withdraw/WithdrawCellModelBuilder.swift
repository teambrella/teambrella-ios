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
    let isValid: Bool
}

struct WalletInfoCellModel: WithdrawCellModel {
    let amount: Ether
    let reserved: Ether
    let available: Ether
    let currencyRate: Double
    let warning: String
    
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
            cell.amountLabel.font = UIFont.teambrellaBold(size: 11)
            cell.cryptoAmountTextField.placeholder = model.amountPlaceholder
            cell.cryptoAmountTextField.text = model.amountValue
            cell.submitButton.setTitle(model.buttonTitle, for: .normal)
            
            //          cell.cryptoAmountTextField.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            //            cell.cryptoAmountTextField.text = model.amountValue
            //            cell.cryptoAmountTextField.tintColor = cell.textField.tintColor.withAlphaComponent(1)
            //            // cell.cryptoAmountTextField.tag = indexPath.row
            //            cell.cryptoAmountTextField.removeTarget(reportVC, action: nil, for: .allEvents)
            //            cell.cryptoAmountTextField.addTarget(delegate, action: #selector(ReportVC.textFieldDidChange),
            //                                                 for: .editingChanged)
            //            cell.cryptoAddressTextView.text = model.toValue
            //            // cell.cryptoAddressTextView.tag = indexPath.row
            //            cell.cryptoAddressTextView.delegate = delegate
            //          cell.cryptoAddressTextView.isInAlertMode = reportVC.isInCorrectionMode ? !model.isValid : false
            
        } else if let cell = cell as? WithdrawCell, let model = model as? WithdrawTransactionCellModel {
            cell.upperLabel.text = model.topText
            cell.lowerLabel.text = model.bottomText
            cell.rightLabel.text = model.amountText
            if !model.isValid {
                cell.indicatorView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                cell.indicatorView.isHidden = false
            } else {
                cell.indicatorView.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.2, blue: 0.5176470588, alpha: 1)
                cell.indicatorView.isHidden = !model.isNew
            }
        } else if let cell = cell as? WalletInfoCell, let model = model as? WalletInfoCellModel {
            populateWalletInfo(cell: cell, model: model)
        }
    }
    
    private static func populateWalletInfo(cell: WalletInfoCell, model: WalletInfoCellModel) {
        cell.amount.text = String.formattedNumber(floor(MEth(model.amount).value))
        cell.currencyLabel.text = service.session?.cryptoCoin.code
        if let team = service.session?.currentTeam {
            let fiatAmount = floor(model.amount.value * model.currencyRate)
            cell.auxillaryAmount.text = String.formattedNumber(fiatAmount) + " " + team.currency
        }
    }
}
