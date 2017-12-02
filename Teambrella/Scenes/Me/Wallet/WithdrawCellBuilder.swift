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

import Kingfisher
import UIKit

struct WithdrawCellBuilder {
    static func populate(cell: UICollectionViewCell/*, with transaction: WithdrawCellModels*/) {
        if let cell = cell as? WithdrawDetailsCell {
            cell.titleLabel.text = "Me.Wallet.Withdraw.Details.title".localized
            cell.toLabel.text = "Me.Wallet.Withdraw.Details.to.title".localized
            cell.cryptoAddressTextField.placeholder = "Me.Wallet.Withdraw.Details.to.placeholder".localized
            cell.amountLabel.text = "Me.Wallet.Withdraw.Details.amount.title".localized
            cell.cryptoAmountTextField.placeholder = "Me.Wallet.Withdraw.Details.amount.placeholder".localized
            cell.submitButton.setTitle("Me.Wallet.Withdraw.Details.submitButton.title".localized, for: .normal)
        } else if let cell = cell as? WithdrawCell {
//            cell.upperLabel.text = transaction.date
//            cell.lowerLabel.text = transaction.address
//            cell.rightLabel.text = transaction.amount
//            cell.indicatorView.isHidden = transaction.isLast
        }
    }
    
}
