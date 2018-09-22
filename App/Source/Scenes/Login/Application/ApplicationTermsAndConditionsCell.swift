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

class ApplicationTermsAndConditionsCell: UICollectionViewCell {
    @IBOutlet var textView: UITextView!
    
    
}

extension ApplicationTermsAndConditionsCell: ApplicationCell {
    func setup(with model: ApplicationCellModel) {
        guard let model = model as? ApplicationTermsAndConditionsCellModel else {
            fatalError("Wrong model type")
        }
        
        textView.attributedText = model.text
        textView.delegate = self
    }
}

extension ApplicationTermsAndConditionsCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        print(URL)
        return true
    }
}
