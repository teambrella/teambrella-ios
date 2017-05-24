//
//  LoginDetailsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class LoginDetailsVC: UIViewController {
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var genderControl: UISegmentedControl!
    
    var user: FacebookUser!
    var isWaitingInput = true {
        didSet {
            registerButton.isEnabled = !isWaitingInput
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.delegate = self
        registerButton.isEnabled = false

        greetingLabel.text = "Hello, \(user.name)"
        var dateComponents = DateComponents()
        dateComponents.year = -user.minAge
        datePicker.date = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()
        genderControl.selectedSegmentIndex = user.gender == .male ? 0 : 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapRegister(_ sender: Any) {
        performSegue(type: .main)
    }

}

extension LoginDetailsVC: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        isWaitingInput = textField.text?.isEmpty ?? true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isWaitingInput = textField.text?.isEmpty ?? true
    }
}
