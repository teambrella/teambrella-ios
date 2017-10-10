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

final class LoginBlueVC: UIViewController {
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var continueWithFBButton: UIButton!
    @IBOutlet var tryDemoButton: UIButton!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var confetti: SKView!
    
    var isEmitterAdded: Bool = false
    
    lazy var secretRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(secretTap))
        recognizer.minimumPressDuration = 8
        return recognizer
    }()
    
    var isRegisteredFacebookUser: Bool { return Keychain.value(forKey: .ethPrivateAddress) != nil }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerLabel.text = "Login.LoginBlueVC.centerLabel".localized
        continueWithFBButton.setTitle("Login.LoginBlueVC.continueWithFBButton".localized, for: .normal)
        tryDemoButton.setTitle("Login.LoginBlueVC.tryDemoButton".localized, for: .normal)
        continueWithFBButton.layer.cornerRadius = 2
        centerLabel.isUserInteractionEnabled = true
        centerLabel.addGestureRecognizer(secretRecognizer)
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
    
    // MARK: Callbacks
    
    @IBAction func tapContinueWithFBButton(_ sender: Any) {
//        guard isRegisteredFacebookUser == false else {
//            logAsFacebookUser(user: nil)
//            return
//        }
        
        let manager = FBSDKLoginManager()
        manager.logOut()
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
        service.crypto.clearLastUserType()
    }
    
    @objc
    private func secretTap(sender: UILongPressGestureRecognizer) {
        let controller = UIAlertController(title: "Secret entrance",
                                           message: "Insert secret BTC key",
                                           preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "BTC private key"
            textField.keyboardType = .default
        }
        
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            if let textField = controller.textFields?.first,
                let text = textField.text,
                text.count > 10 {
                self?.setupBTCsecretAddress(string: text)
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginDetailsVC, let user = sender as? FacebookUser {
            _ = LoginDetailsConfigurator(vc: vc, fbUser: user)
        }
    }
    
    // MARK: Private
    
    private func addEmitter() {
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
    
    private func animateCenterLabel() {
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
    
    private func register(token: String, userID: String) {
        service.crypto.setToRealUser()
        
        guard let signature = EthereumProcessor.standard.publicKeySignature else {
            let error = TeambrellaErrorFactory.malformedETCsignature()
            service.error.present(error: error)
            service.router.logout()
            return
        }
        
        service.server.updateTimestamp { timestamp, error in
            let body = RequestBody(key: service.server.key, payload: ["facebookToken": token,
                                                                      "sigOfPublicKey": signature])
            let request = TeambrellaRequest(type: .registerKey, parameters: ["facebookToken": token,
                                                                             "sigOfPublicKey": signature],
                                            body: body,
                                            success: { response in
                                                self.getMe()
            }) { error in
                self.handleFailure(error: error)
            }
            request.start()
        }
    }
    
    private func getMe() {
        let fields = "email, birthday, age_range, name, first_name, last_name, gender, picture.type(large)"
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": fields]).start { connection, object, error in
            guard let reply = object as? [String: Any], error == nil else {
                self.handleFailure(error: error)
                return
            }
            log("Facebook reply: \(reply)", type: .social)
            self.handleSuccess(facebookUser: FacebookUser(dict: reply))
        }
    }
    
   private func handleSuccess(facebookUser: FacebookUser) {
      logAsFacebookUser(user: facebookUser)
    }
    
    private func handleFailure(error: Error?) {
        HUD.hide()
        service.crypto.clearLastUserType()
        performSegue(type: .invitationOnly, sender: nil)
        log("Error \(String(describing: error))", type: .error)
    }
    
    private func setupBTCsecretAddress(string: String) {
        let demo = Keychain.value(forKey: .ethPrivateAddressDemo)
        guard demo != string else {
            return
        }
        
        Keychain.save(value: string, forKey: .ethPrivateAddress)
        logAsFacebookUser(user: nil)
    }
    
    private func logAsFacebookUser(user: FacebookUser?) {
        HUD.hide()
        service.crypto.setToRealUser()
        performSegue(type: .unwindToInitial, sender: user)
    }
    
}
