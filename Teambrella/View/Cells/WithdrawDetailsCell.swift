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
    @IBOutlet var cryptoAddressTextView: UITextView!
    @IBOutlet var qrButton: BorderedButton!
    @IBOutlet var amountLabel: InfoLabel!
    @IBOutlet var cryptoAmountTextField: UITextField!
    @IBOutlet var separator: UIView!
    @IBOutlet var submitButton: BorderedButton!
    @IBOutlet var placeholder: UILabel!
    
    var onValuesChanged: ((WithdrawDetailsCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let label = LabeledIcon(frame: CGRect(x: 0, y: 0, width: 60, height: 39))
        cryptoAmountTextField.leftViewMode = .always
        cryptoAmountTextField.leftView = label
        cryptoAmountTextField.layer.masksToBounds = true
        cryptoAmountTextField.layer.borderWidth = 0.5
        cryptoAmountTextField.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        cryptoAmountTextField.layer.cornerRadius = 5
        
        cryptoAddressTextView.layer.borderWidth = 0.5
        cryptoAddressTextView.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        cryptoAddressTextView.layer.cornerRadius = 5
        placeholder.text = "Me.Wallet.Withdraw.Details.to.placeholder".localized
        cryptoAmountTextField.placeholder = "Me.Wallet.Withdraw.Details.amount.placeholder".localized
        ViewDecorator.shadow(for: self)
        cryptoAddressTextView.delegate = self
        cryptoAmountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        cryptoAmountTextField.delegate = self
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }
    
    @objc
    func amountChanged() {
        onValuesChanged?(self)
    }
}

// MARK: UITextViewDelegate
extension WithdrawDetailsCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        (textView as? TextView)?.isInEditMode = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        (textView as? TextView)?.isInAlertMode = false
        (textView as? TextView)?.isInEditMode = true
        if textView.text == nil || textView.text == "" {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
        onValuesChanged?(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        (textView as? TextView)?.isInEditMode = false
        if textView.text == nil || textView.text == "" {
            placeholder.isHidden = false
        }
        onValuesChanged?(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let input = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return input.count <= 42;
    }
}

extension WithdrawDetailsCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        (textField as? TextField)?.isInAlertMode = false
        (textField as? TextField)?.isInEditMode = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? TextField)?.isInEditMode = false
    }
}
