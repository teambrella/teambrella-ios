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
    
    var cryptoBalance: Double = 0.0
    var cryptoReserved: Double = 0.0
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
        
        
        mayRequestLabel.attributedText =
            decorateString(string: "Me.Wallet.Withdraw.WithdrawInfo.youMayRequest".localized,
                                              amount: String.truncatedNumber((cryptoBalance - cryptoReserved) * 1000),
                                              currency: "mETH")
            //"Me.Wallet.Withdraw.WithdrawInfo.youMayRequest".localized(
            //String.truncatedNumber((cryptoBalance - cryptoReserved) * 1000))
        haveLabel.text = cryptoReserved == 0 ? "" : "Me.Wallet.Withdraw.WithdrawInfo.youHave".localized(
                String.truncatedNumber(cryptoReserved * 1000))
    }
    
    func decorateString(string: String, amount: String, currency: String) -> NSAttributedString {
        var amountAttributes = [NSAttributedStringKey : Any]()
        amountAttributes[NSAttributedStringKey.foregroundColor] = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        amountAttributes[NSAttributedStringKey.font] = UIFont.teambrella(size: 12)
        
        var currencyAttributes = [NSAttributedStringKey : Any]()
        currencyAttributes[NSAttributedStringKey.foregroundColor] = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        currencyAttributes[NSAttributedStringKey.font] = UIFont.teambrella(size: 8)
        
        let amountDecorated = NSMutableAttributedString(string: amount,
                                                        attributes: amountAttributes)
        let currencyDecorated = NSMutableAttributedString(string: currency,
                                                          attributes: currencyAttributes)
        var result = NSMutableAttributedString(string: string)
        result.append(amountDecorated)
        result.append(currencyDecorated)
        
        return result
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    @IBAction func tapClose(_ sender: Any) {
        disappear {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func appear() {
        self.bottomConstraint.constant = bottomOffset //-8
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
