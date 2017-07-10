//
//  LoginNoInviteVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 10.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class LoginNoInviteVC: UIViewController {
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var subcontainer: UIView!
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var tryDemoButton: UIButton!
    
    @IBAction func tapTryDemoButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subcontainer.layer.cornerRadius = 4
        centerLabel.text = "Login.LoginNoInviteVC.centerLabel".localized
        upperLabel.text = "Login.LoginNoInviteVC.upperLabel".localized
        lowerLabel.text = "Login.LoginNoInviteVC.lowerLabel".localized
        tryDemoButton.setTitle("Login.LoginNoInviteVC.tryDemoButton".localized, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
