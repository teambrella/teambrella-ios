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

    var viewWasShown: Bool {
        get {
            if SimpleStorage().string(forKey: .swipeHelperWasShown) != nil {
                return true
            }
            return false
        }
        set {
            SimpleStorage().store(bool: true, forKey: .swipeHelperWasShown)
        }
    }
    
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
        self.isHidden = viewWasShown
        
        label.text = "Team.Vote.SwipeToVote".localized
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeView))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(closeView))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(closeView))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        backView.addGestureRecognizer(tap)
        backView.addGestureRecognizer(swipeLeft)
        backView.addGestureRecognizer(swipeRight)
    }
    
    @objc
    func closeView() {
        self.isHidden = true
        viewWasShown = true
    }

}
