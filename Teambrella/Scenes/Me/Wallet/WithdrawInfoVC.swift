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

class WithdrawInfoVC: UIViewController, Routable {
    
    static let storyboardName = "Me"
    
    var cryptoBalance: Ether = Ether.empty
    var cryptoReserved: Ether = Ether.empty
    var bottomOffset: CGFloat = -8
    
    @IBOutlet var backView: UIView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var separator: UIView!
    @IBOutlet var balanceLabel: MessageTitleLabel!
    @IBOutlet var mayRequestLabel: ChatTextLabel!
    @IBOutlet var haveLabel: ChatTextLabel!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.layer.cornerRadius = 4
        headerLabel.text = "Me.Wallet.Withdraw.WithdrawInfo.title".localized
        balanceLabel.text = "Me.Wallet.Withdraw.WithdrawInfo.balance".localized
        
        let currency = "mETH"
        let mayRequestAmount = String.truncatedNumber(MEth(cryptoBalance - cryptoReserved).value)
        let mayRequestString = "Me.Wallet.Withdraw.WithdrawInfo.youMayRequest".localized(mayRequestAmount)
        let mayRequestAttributed = NSMutableAttributedString(string: mayRequestString)
            .decorate(substring: mayRequestAmount, type: .boldAmount)
            .decorate(substring: currency, type: .currency)
        mayRequestLabel.attributedText = mayRequestAttributed
        
        let haveValue = String.truncatedNumber(MEth(cryptoReserved).value)
        let haveString = cryptoReserved.value == 0 ? "" : "Me.Wallet.Withdraw.WithdrawInfo.youHave".localized(haveValue)
        let haveAttributed = NSMutableAttributedString(string: haveString)
            .decorate(substring: haveValue, type: .boldAmount)
            .decorate(substring: currency, type: .currency)
        haveLabel.attributedText = haveAttributed
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapClose))
        recognizer.delegate = self
        backView.addGestureRecognizer(recognizer)
        backView.isUserInteractionEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    @objc
    @IBAction func tapClose(_ sender: Any) {
        disappear {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func appear() {
        self.bottomConstraint.constant = bottomOffset
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        self.bottomConstraint.constant = -self.infoView.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.backView.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }) { finished in
            completion()
        }
    }
}

extension WithdrawInfoVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
