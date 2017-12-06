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

class WithdrawInfoVC: UIViewController {

    static let storyboardName = "Me"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var separator: UIView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var mayRequestLabel: UILabel!
    @IBOutlet var haveLabel: UILabel!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoView.layer.cornerRadius = 4
        headerLabel.text = "Team.Chat.NotificationSettings.title".localized
        balanceLabel.text = "Balance"
        mayRequestLabel.text = "You may request up to balance amount for withdrawal 184 mETH."
        haveLabel.text = "You have 22 mETH reserved, if some part of the reserved funds becomes available, it would be automatically scheduled for the withdrawal."
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
        self.bottomConstraint.constant = -8
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
