//
//  LoginBlueVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 10.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit

class LoginBlueVC: UIViewController {

    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var continueWithFBButton: UIButton!
    @IBOutlet var tryDemoButton: UIButton!
    
    @IBAction func tapContinueWithFBButton(_ sender: Any) {
        let manager = FBSDKLoginManager()
        let permissions = ["public_profile", "email", "user_friends"]
        HUD.show(.progress)
        manager.logIn(withReadPermissions: permissions, from: self) { [weak self] result, error in
            guard let me = self else { return }
            guard error == nil, let result = result, let token = result.token else {
                me.handleFailure(error: error)
                return
            }
            
            me.register(token: token.tokenString)
        }
    }
    
    @IBAction func tapTryDemoButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerLabel.text = "Login.LoginBlueVC.centerLabel".localized
        continueWithFBButton.setTitle("Login.LoginBlueVC.continueWithFBButton".localized, for: .normal)
        tryDemoButton.setTitle("Login.LoginBlueVC.tryDemoButton".localized, for: .normal)
        continueWithFBButton.layer.cornerRadius = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func register(token: String) {
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.privateKey, timestamp: timestamp)
            let body = RequestBody(key: key)
            let request = TeambrellaRequest(type: .registerKey, parameters: ["facebookToken": token],
                                            body: body,
                                            success: { response in
                                                self.getMe()
                                                // self.handleSuccess()
            }) { error in
                self.handleFailure(error: error)
            }
            request.start()
        }
    }
    
    func getMe() {
        let fields = "email, birthday, age_range, name, first_name, last_name, gender, picture.type(large)"
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": fields]).start { connection, object, error in
            guard let reply = object as? [String: Any], error == nil else {
                self.handleFailure(error: error)
                return
            }
            print(reply)
            self.handleSuccess(facebookUser: FacebookUser(dict: reply))
        }
    }
    
    func handleSuccess(facebookUser: FacebookUser) {
        HUD.hide()
        performSegue(type: .details, sender: facebookUser)
    }
    
    func handleFailure(error: Error?) {
        HUD.hide()
        print("Error \(String(describing: error))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginDetailsVC, let user = sender as? FacebookUser {
            _ = LoginDetailsConfigurator(vc: vc, fbUser: user)
        }
    }

}
