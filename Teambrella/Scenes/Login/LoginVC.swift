//
//  LoginVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapLogin(_ sender: UIButton) {
        let manager = FBSDKLoginManager()
        let permissions = ["public_profile", "email", "user_friends"]
        activityIndicator.startAnimating()
        manager.logIn(withReadPermissions: permissions, from: self) { [weak self] result, error in
            guard let me = self else { return }
            guard error == nil, let result = result, let token = result.token else {
                me.handleFailure(error: error)
                return
            }
            
            me.register(token: token.tokenString)
        }
    }
    
    func register(token: String) {
      //let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: service.server.timestamp)
        let request = TeambrellaRequest(type: .registerKey, parameters: ["facebookToken": token],
                                        body: nil,
                                        success: { response in
                         self.handleSuccess()
        }) { error in
            self.handleFailure(error: error)
        }
        request.start()
    }
    
    func handleSuccess() {
        activityIndicator.stopAnimating()
        performSegue(withIdentifier: "to main", sender: self)
    }
    
    func handleFailure(error: Error?) {
        activityIndicator.stopAnimating()
        print("Error \(error)")
    }
    
}
