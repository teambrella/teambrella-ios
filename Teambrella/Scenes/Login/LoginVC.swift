//
//  LoginVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftyJSON
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
    
    deinit {
        print("LoginVC deinit")
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
        activityIndicator.stopAnimating()
        performSegue(type: .details, sender: facebookUser)
    }
    
    func handleFailure(error: Error?) {
        activityIndicator.stopAnimating()
        print("Error \(String(describing: error))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginDetailsVC, let user = sender as? FacebookUser {
            _ = LoginDetailsConfigurator(vc: vc, fbUser: user)
        }
    }
    
}
