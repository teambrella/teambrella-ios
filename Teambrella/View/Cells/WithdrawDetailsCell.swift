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

import UIKit

class WithdrawDetailsCell: UICollectionViewCell, XIBInitableCell {

    @IBOutlet var backView: UIView!
    @IBOutlet var titleLabel: BlockHeaderLabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var toLabel: InfoLabel!
    @IBOutlet var cryptoAddressTextField: UITextField!
    @IBOutlet var qrButton: BorderedButton!
    @IBOutlet var amountLabel: InfoLabel!
    @IBOutlet var cryptoAmountTextField: UITextField!
    @IBOutlet var separator: UIView!
    @IBOutlet var submitButton: BorderedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cryptoAmountTextField.placeholder = ""
        //cryptoAddressTextField.placeholder = "Me.Wallet.Withdraw.Details.to.placeholder".localized
        cryptoAmountTextField.placeholder = "Me.Wallet.Withdraw.Details.amount.placeholder".localized
        ViewDecorator.shadow(for: self)
    }

    @IBAction func tapInfoButton(_ sender: Any) {
        
    }
    
    @IBAction func tapQrButton(_ sender: Any) {
    }
    
    @IBAction func tapSubmitButton(_ sender: Any) {
    }
}
