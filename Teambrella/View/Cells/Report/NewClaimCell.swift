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

class NewClaimCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var backView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var objectNameLabel: MessageTitleLabel!
    @IBOutlet var objectDetailsLabel: InfoLabel!
    @IBOutlet var objectImageView: UIImageView!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var dateLabel: InfoLabel!
    @IBOutlet var dateTextField: TextField!
    @IBOutlet var expensesLabel: InfoLabel!
    @IBOutlet var expensesTextField: TextField!
    @IBOutlet var currencyTextField: TextField!
    @IBOutlet var statsNumberBar: NumberBar!
    @IBOutlet var descriptionLabel: InfoLabel!
    @IBOutlet var descriptionTextView: TextView!
    @IBOutlet var photosLabel: InfoLabel!
    @IBOutlet var photosContainer: UIView!
    @IBOutlet var addPhotosButton: BorderedButton!
    @IBOutlet var reimburseLabel: InfoLabel!
    @IBOutlet var reimburseTextField: TextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        objectImageView.layer.cornerRadius = 3
        statsNumberBar.left?.isBadgeVisible = false
        statsNumberBar.middle?.isBadgeVisible = false
        statsNumberBar.right?.isBadgeVisible = false
        descriptionTextView.layer.masksToBounds = true
        
    }

}
