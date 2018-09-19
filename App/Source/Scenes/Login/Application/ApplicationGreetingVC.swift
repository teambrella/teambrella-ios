//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

class ApplicationGreetingVC: UIViewController, Routable {
static let storyboardName = "Login"
    
    @IBOutlet var cardView: RoundedCornersView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var facebookButton: BorderedButton!
    @IBOutlet var vkButton: BorderedButton!
    
    var onFacebookButtonTap: (() -> Void)?
    var onVKButtonTap: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCard()
    }
    
    func setupCard() {
        ViewDecorator.shadow(for: cardView, opacity: 0.5, radius: 5)
    }

    @IBAction func tapButton(_ sender: UIButton) {
        print("tap \(sender)")
        switch sender {
        case facebookButton:
            onFacebookButtonTap?()
        case vkButton:
             onVKButtonTap?()
        default:
            break
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
