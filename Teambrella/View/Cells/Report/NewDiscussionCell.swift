//
/* Copyright(C) 2018 Teambrella, Inc.
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

class NewDiscussionCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var backView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var textFieldTitleLabel: InfoLabel!
    @IBOutlet var titleTextField: TextField!
    @IBOutlet var textViewTitleLabel: InfoLabel!
    @IBOutlet var postTextView: TextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postTextView.layer.masksToBounds = true
        postTextView.layer.borderWidth = 1
        postTextView.layer.cornerRadius = 3
        postTextView.layer.borderColor = #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
    }

}
