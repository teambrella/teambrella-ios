//
//  LoginDetailsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
