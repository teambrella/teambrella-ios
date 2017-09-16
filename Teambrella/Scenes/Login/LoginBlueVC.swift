//
//  LoginBlueVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 10.07.17.

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

import PKHUD
import SpriteKit
import UIKit

class LoginBlueVC: UIViewController {
    
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var continueWithFBButton: UIButton!
    @IBOutlet var tryDemoButton: UIButton!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var confetti: SKView!
    
    var isEmitterAdded: Bool = false
    let validUsers: [String: ServerService.FakeKeyType] = ["10212220476497327": .thorax,
                                                           "10213031213152997": .denis,
                                                           "10155873130993128": .kate,
                                                           "10205925536911596": .eugene
    ]
    
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
            me.register(token: token.tokenString, userID: token.userID)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerLabel.alpha = 0
        gradientView.alpha = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.gradientView.alpha = 1
        }
        animateCenterLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addEmitter()
    }
    
    func addEmitter() {
        guard !isEmitterAdded else { return }
        
        isEmitterAdded = true
        let skScene: SKScene = SKScene(size: confetti.frame.size)
        skScene.scaleMode = .aspectFit
        skScene.backgroundColor = .clear
        if let emitter: SKEmitterNode = SKEmitterNode(fileNamed: "Fill.sks") {
            emitter.particleBirthRate = 0.3
            emitter.position = CGPoint(x: confetti.center.x, y: 0)
            emitter.particleRotationRange = CGFloat.pi * 2
            emitter.particleRotation = 0
            emitter.particleRotationSpeed = CGFloat.pi / 2
            skScene.addChild(emitter)
            
        }
        if let emitter: SKEmitterNode = SKEmitterNode(fileNamed: "Fill.sks") {
            emitter.particleBirthRate = 0.4
            emitter.position = CGPoint(x: confetti.center.x, y: 0)
            emitter.particleRotationRange = CGFloat.pi * 2
            emitter.particleRotation = 0
            emitter.particleRotationSpeed = -CGFloat.pi / 2
            skScene.addChild(emitter)
        }
        
        confetti.allowsTransparency = true
        confetti.presentScene(skScene)
    }
    
    func animateCenterLabel() {
        let offset: CGFloat = view.bounds.height / 2 - 50
        let offsetTransform = CGAffineTransform(translationX: 0, y: offset)
        let scaleTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        centerLabel.transform = offsetTransform.concatenating(scaleTransform)
        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self?.centerLabel.alpha = 1
                        self?.centerLabel.transform = .identity
            },
                       completion: nil)
    }
    
    func register(token: String, userID: String) {
//        guard let validUser = validUsers[userID] else {
//            performSegue(type: .invitationOnly, sender: nil)
//            return
//        }
        
        // WARNING: TMP validUser!
        let validUser: ServerService.FakeKeyType = .thorax
        Keychain.save(value: validUser.rawValue, forKey: .ethPrivateAddress)
        ServerService.currentKeyType = validUser
        
        guard let signature = EthereumProcessor.standard.publicKeySignature else {
            fatalError("Malformed ETH signature")
            
        }
        
        service.server.updateTimestamp { timestamp, error in
            let body = RequestBody(key: service.server.key, payload: ["facebookToken": token,
                                                                      "sigOfPublicKeyHash": signature])
            let request = TeambrellaRequest(type: .registerKey, parameters: ["facebookToken": token,
                                                                             "sigOfPublicKeyHash": signature],
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
        performSegue(type: .unwindToInitial, sender: facebookUser)
    }
    
    func handleFailure(error: Error?) {
        HUD.hide()
        performSegue(type: .invitationOnly, sender: nil)
        print("Error \(String(describing: error))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginDetailsVC, let user = sender as? FacebookUser {
            _ = LoginDetailsConfigurator(vc: vc, fbUser: user)
        }
    }
    
}
