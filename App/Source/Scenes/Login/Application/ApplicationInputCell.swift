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

class ApplicationInputCell: UICollectionViewCell, ApplicationCellDecorable {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var headlightLabel: UILabel!
    @IBOutlet var inputTextField: TextField!
    var isDecorated: Bool = false
    
    var onTextChange: ((TextField)-> Void)?
    
    private func setup() {
        inputTextField.addTarget(self, action: #selector(changeText), for: .editingChanged)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @objc
    private func changeText(textField: TextField) {
        onTextChange?(textField)
    }
    
    func decorate() {
        guard !isDecorated else { return }
        
        ViewDecorator.homeCardShadow(for: self, offset: CGSize(width: 0, height: 9))
        isDecorated = true
    }
}

extension ApplicationInputCell: ApplicationCell {
    func setup(with model: ApplicationCellModel) {
        guard let model = model as? ApplicationInputCellModel else {
            fatalError("Wrong model type")
        }
        
        textLabel.text = model.text
        headlightLabel.text = model.headlightText
        inputTextField.text = model.inputText
        inputTextField.placeholder = model.placeholderText
    }
}
