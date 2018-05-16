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

class ChatClaimPaidCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var confettiView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var button: UIButton!

    var onButtonTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        containerView.layer.cornerRadius = 6
        containerView.backgroundColor = .perrywinkle
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.cornflowerBlueThree.cgColor

        separatorView.backgroundColor = .lavender
    }

    @IBAction func tapButton(_ sender: UIButton) {
        onButtonTap?()
    }
}
