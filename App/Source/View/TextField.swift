//
//  TextField.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.09.17.
/* Copyright(C) 2017  Teambrella, Inc.
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
//

import UIKit

class TextField: UITextField {
    private lazy var alertDecorator = { AlertDecorator(view: self) }()
    var isInAlertMode: Bool {
        get { return alertDecorator.isInAlertMode }
        set { alertDecorator.isInAlertMode = newValue }
    }
    private lazy var editDecorator = { EditDecorator(view: self) }()
    var isInEditMode: Bool {
        get { return editDecorator.isInEditMode }
        set { editDecorator.isInEditMode = newValue }
    }
    
    var isAutocompleteEnabled: Bool = false {
        didSet {
            if isAutocompleteEnabled {
                delegate = self
            }
        }
    }
    var suggestions: [String]?
    private var inputCount: Int = 0
    private var timer = Timer()
    
    deinit {
        timer.invalidate()
    }
    
    func resetValues() {
        inputCount = 0
        text = ""
    }
    
    func formatSubstring(subString: String) -> String {
        let formatted = String(subString.dropLast(inputCount)).lowercased().capitalized //5
        return formatted
    }
    
    func searchAutocompleteEntriesWIthSubstring(substring: String) {
        let userQuery = substring
        let suggestions = getAutocompleteSuggestions(userText: substring) //1
        
        if !suggestions.isEmpty {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { timer in //2
                let autocompleteResult = self.formatAutocompleteResult(substring: substring,
                                                                       possibleMatches: suggestions) // 3
                self.putColorFormattedText(text: autocompleteResult, original: userQuery) //4
                self.moveCaretToEndOf(userQuery: userQuery) //5
            })
        } else {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { timer in //7
                self.text = substring
            })
            inputCount = 0
        }
    }
    
    func putColorFormattedText(text: String, original: String) {
        let coloredString: NSMutableAttributedString = NSMutableAttributedString(string: original + text)
        coloredString.addAttribute(NSAttributedString.Key.foregroundColor,
                                   value: UIColor.green,
                                   range: NSRange(location: original.count, length: text.count))
        self.attributedText = coloredString
    }
    func moveCaretToEndOf(userQuery: String) {
        if let newPosition = self.position(from: self.beginningOfDocument, offset: userQuery.count) {
            self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
        }
        guard let selectedRange: UITextRange = self.selectedTextRange else { return }
 
        self.offset(from: self.beginningOfDocument, to: selectedRange.start)
    }
    
    func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
        var auto = possibleMatches[0]
        auto.removeSubrange(auto.startIndex..<auto.index(auto.startIndex, offsetBy: substring.count))
        inputCount = auto.count
        return auto
    }
    
    func getAutocompleteSuggestions(userText: String) -> [String] {
        guard let suggestions = suggestions else { return [] }
        
//        var possibleMatches: [String] = []
//        for item in suggestions { //2
//            let myString: NSString! = item as NSString
//            let substringRange: NSRange! = myString.range(of: userText)
//
//            if substringRange.location == 0 {
//                possibleMatches.append(item)
//            }
//        }
        return suggestions
    }
    
}

extension TextField: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        var subString = ""
        if let text = textField.text {
            subString = (text.capitalized as NSString).replacingCharacters(in: range, with: string)
        }
        subString = formatSubstring(subString: subString)
        
        if subString.isEmpty {
            resetValues()
        } else {
            searchAutocompleteEntriesWIthSubstring(substring: subString) //4
        }
        return true
    }
}

class TextView: UITextView {
    private lazy var alertDecorator = { AlertDecorator(view: self) }()
    var isInAlertMode: Bool {
        get { return alertDecorator.isInAlertMode }
        set { alertDecorator.isInAlertMode = newValue }
    }
    private lazy var editDecorator = { EditDecorator(view: self) }()
    var isInEditMode: Bool {
        get { return editDecorator.isInEditMode }
        set { editDecorator.isInEditMode = newValue }
    }
}

class AlertDecorator {
    weak var view: UIView?
    var alertBorderColor: UIColor = .red
    var normalBorderColor: UIColor = .cloudyBlue
    var isInAlertMode: Bool {
        didSet {
            guard let view = view else { return }
            
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 3
            view.clipsToBounds = true
            view.layer.borderColor = isInAlertMode ? alertBorderColor.cgColor : normalBorderColor.cgColor
        }
    }
    
    init(view: UIView) {
        self.view = view
        self.isInAlertMode = false
    }
    
}

class EditDecorator {
    weak var view: UIView?
    var normalBorderColor: UIColor = .cloudyBlue
    var editBorderColor: UIColor = .bluishGray
    
    var isInEditMode: Bool {
        didSet {
            guard let view = view else { return }
            
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 3
            view.clipsToBounds = true
            view.layer.borderColor = isInEditMode ? editBorderColor.cgColor : normalBorderColor.cgColor
        }
    }
    
    init(view: UIView) {
        self.view = view
        self.isInEditMode = false
    }
    
}
