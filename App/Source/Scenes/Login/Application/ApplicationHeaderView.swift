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

class ApplicationHeaderView: UICollectionReusableView, ApplicationCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    func setup(with model: ApplicationCellModel) {
        guard let model = model as? ApplicationHeaderCellModel else {
            fatalError("Wrong header model")
        }
        
        imageView.showImage(string: model.image)
        nameLabel.text = model.name
        cityLabel.text = model.city
        
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
    }
    
}
