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

class SwipeToVote: UIView, XIBInitable {

    @IBOutlet var backView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    var contentView: UIView!
    
    var onInteraction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setup()
    }
    
    func setup() {
        self.isHidden = SimpleStorage().bool(forKey: .swipeHelperWasShown)
        
        label.text = "Team.Vote.SwipeToVote".localized
        imageView.image = #imageLiteral(resourceName: "swipe left-right")
        self.isUserInteractionEnabled = false
    }
    
    @objc
    func closeView() {
        self.onInteraction?()
    }
    
    func appear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.isHidden = false
            self.backView.alpha = 1
        }) { finished in
            
        }
        self.disappear(duration: 0.5, delay: 1.5)
    }

    func disappear(duration: Double, delay: Double) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
            self.backView.alpha = 0
            self.onInteraction?()
        }) { finished in
            
        }
    }
}
