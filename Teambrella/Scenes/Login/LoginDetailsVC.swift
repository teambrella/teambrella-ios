//
//  LoginDetailsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.

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

import Kingfisher
import UIKit

class LoginDetailsVC: UIViewController {
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var genderControl: UISegmentedControl!
    @IBOutlet var avatarView: RoundImageView!
    
    var presenter: LoginDetailsPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
        
        listenForKeyboard()
    }
    
    deinit {
        print("LoginDetailsVC deinit")
    }
    
    @IBAction func tapRegister(_ sender: Any) {
        presenter?.tapRegister()
    }
    
    @objc
    func textChanged() {
        presenter?.codeTextChanged(text: codeTextField.text)
    }
    
}

extension LoginDetailsVC: LoginDetailsView {
    var code: String? { return codeTextField.text }
    var gender: Gender { return genderControl.selectedSegmentIndex == 0 ? .male : .female }
    var date: Date { return datePicker.date }
    
    func register(enable: Bool) {
        registerButton.isEnabled = enable
    }
    
    func greeting(text: String) {
        greetingLabel.text = text
    }
    
    func changeDate(to date: Date) {
        datePicker.date = date
    }
    
    func changeGender(to gender: Gender) {
        genderControl.selectedSegmentIndex = gender == .male ? 0 : 1
    }
    
    func showAvatar(url: URL) {
        avatarView.kf.setImage(with: url)
    }
}
