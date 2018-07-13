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

class TeammateSummaryView: UICollectionReusableView, XIBInitableCell, AmountUpdatable {
    @IBOutlet var avatarView: GalleryView!
    @IBOutlet var infoLabel: Label!
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    @IBOutlet var title: Label!
    @IBOutlet var subtitle: Label!
    @IBOutlet var radarView: RadarView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         avatarView.layer.cornerRadius = avatarView.frame.width / 2
    }
    
}
