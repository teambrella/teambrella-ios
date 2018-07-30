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
    var didTapDemo: Bool = false

    var loginWorker: LoginWorker!
    
    lazy var secretRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(secretTap))
        recognizer.minimumPressDuration = 8
        return recognizer
    }()
    
    lazy var clearAllRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(clearAllTap))
        recognizer.minimumPressDuration = 8
        return recognizer
    }()
    
    var isRegisteredFacebookUser: Bool { return KeychainService().value(forKey: .privateKey) != nil }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerLabel.text = "Login.LoginBlueVC.centerLabel".localized
        continueWithFBButton.setTitle("Login.LoginBlueVC.continueWithFBButton".localized, for: .normal)
        tryDemoButton.setTitle("Login.LoginBlueVC.tryDemoButton".localized, for: .normal)
        continueWithFBButton.layer.cornerRadius = 2
        centerLabel.isUserInteractionEnabled = true
        centerLabel.addGestureRecognizer(secretRecognizer)
        continueWithFBButton.addGestureRecognizer(clearAllRecognizer)
        animateCenterLabel()
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
            self?.centerLabel.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addEmitter()
    }
    
    // MARK: Callbacks
    
    @IBAction func tapContinueWithFBButton(_ sender: Any) {
        guard service.keyStorage.hasRealPrivateKey == false else {
            logAsFacebookUser(user: nil)
            return
        }

        HUD.show(.progress)
        loginWorker.loginAndRegister(in: self, completion: { [weak self] facebookUser in
            self?.logAsFacebookUser(user: facebookUser)
        }) { [weak self] error in
            self?.handleFailure(error: error)
        }
    }
    
    @IBAction func tapTryDemoButton(_ sender: Any) {
        service.keyStorage.setToDemoUser()
        performSegue(withIdentifier: "unwindToInitial", sender: self)
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
                self?.insertSecretKey(string: text)
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc
    private func clearAllTap(sender: UILongPressGestureRecognizer) {
        let controller = UIAlertController(title: "Clear private keys",
                                           message: """
Are you sure you want to completely remove your private key from this device?
""",
                                           preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            service.keyStorage.deleteStoredKeys()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginDetailsVC, let user = sender as? FacebookUser {
            _ = LoginDetailsConfigurator(vc: vc, fbUser: user)
        }
        if let vc = segue.destination as? LoginNoInviteVC {
            let error = sender as? TeambrellaError
            vc.error = error
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
                        self?.centerLabel.transform = .identity
            },
                       completion: nil)
    }
    
    private func handleFailure(error: Error?) {
        HUD.hide()
        service.keyStorage.clearLastUserType()
        performSegue(type: .invitationOnly, sender: error)
        log("Error \(String(describing: error))", type: .error)
    }
    
    private func insertSecretKey(string: String) {
        service.keyStorage.saveNewPrivateKey(string: string)
        logAsFacebookUser(user: nil)
    }
    
    private func logAsFacebookUser(user: FacebookUser?) {
        HUD.hide()
        service.keyStorage.setToRealUser()
        performSegue(withIdentifier: "unwindToInitial", sender: user)
    }
    
}
