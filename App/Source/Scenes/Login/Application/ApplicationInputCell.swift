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
    
    var onTextChange: ((TextField) -> Void)?
    var onUserInput: ((String?) -> Void)?
    var onBeginEditing: ((ApplicationInputCell) -> Void)?
    
    private func setup() {
        inputTextField.addTarget(self, action: #selector(changeText), for: .editingChanged)
        inputTextField.addTarget(self, action: #selector(beginEditing), for: .editingDidBegin)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    @objc
    private func changeText(textField: TextField) {
        onUserInput?(textField.text)
        onTextChange?(textField)
    }
    
    @objc
    private func beginEditing(textField: TextField) {
        onBeginEditing?(self)
    }
    
    func decorate() {
        guard !isDecorated else { return }
        
        //ViewDecorator.homeCardShadow(for: self, offset: CGSize(width: 0, height: 9))
        isDecorated = true
    }
}

extension ApplicationInputCell: ApplicationCell {
    func setup(with model: ApplicationCellModel, userData: UserApplicationData) {
        guard let model = model as? ApplicationInputCellModel else {
            fatalError("Wrong model type")
        }
        
        textLabel.text = model.text
        headlightLabel.text = model.headlightText
        inputTextField.text = userData.text(for: model)
        inputTextField.placeholder = model.placeholderText
        
        switch model.type {
        case .email:
           inputTextField.keyboardType = .emailAddress
        default:
           inputTextField.keyboardType = .default
        }
    }
}

extension ApplicationInputCell: SuggestionsVCDelegate {
    func suggestions(vc: SuggestionsVC, textChanged: String) {
        inputTextField.text = textChanged
    }
    
    func suggestionsVCWillClose(vc: SuggestionsVC) {
        onUserInput?(inputTextField?.text)
    }
}
