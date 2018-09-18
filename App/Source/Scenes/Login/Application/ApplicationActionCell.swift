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

class ApplicationActionCell: UICollectionViewCell {
    @IBOutlet var button: BorderedButton!
    
    var onButtonTap: ((UIButton) -> Void)?
    
    @IBAction func tapButton(_ sender: UIButton) {
        onButtonTap?(sender)
    }
}

extension ApplicationActionCell: ApplicationCell {
    func setup(with model: ApplicationCellModel) {
        guard let model = model as? ApplicationActionCellModel else {
            fatalError("Wrong model type")
        }
        
       button.setTitle(model.buttonText, for: .normal)
    }
}
