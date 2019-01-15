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
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var tryDemoButton: UIButton!
    @IBOutlet var qrCodeButton: UIButton!
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
    
    var canLogWithQRCode: Bool {
        return !service.keyStorage.isRealPrivateKeySet || SimpleStorage().bool(forKey: .isRegistering)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if service.joinTeamID != nil {
            performSegue(type: .welcome)
        }
        
        centerLabel.text = "Login.LoginBlueVC.centerLabel".localized
        nextButton.setTitle("General.forward".localized, for: .normal)
        qrCodeButton.setTitle("Login.QRCodeButton".localized, for: .normal)
        
        tryDemoButton.setTitle("Login.LoginBlueVC.tryDemoButton".localized, for: .normal)
        nextButton.layer.cornerRadius = 2
        
        centerLabel.isUserInteractionEnabled = true
        centerLabel.addGestureRecognizer(secretRecognizer)
        
        nextButton.addGestureRecognizer(clearAllRecognizer)
        //        continueWithFBButton.addGestureRecognizer(clearAllRecognizer)
        animateCenterLabel()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dynamicLinkReceived),
                                               name: .dynamicLinkReceived,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        centerLabel.alpha = 0
        gradientView.alpha = 0
        
        qrCodeButton.isHidden = !canLogWithQRCode
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
    
    @IBAction func tapNextButton() {
        if service.keyStorage.isRealPrivateKeySet && SimpleStorage().bool(forKey: .isRegistering) == false {
            service.keyStorage.setToRealUser()
            performSegue(type: .unwindToInitial)
        } else {
            SimpleStorage().store(bool: true, forKey: .isRegistering)
            performSegue(type: .welcome)
        }
    }
    
    func register(type: LoginWorker.LoginType) {
        guard service.keyStorage.hasRealPrivateKey == false else {
            logIn()
            return
        }
        
        HUD.show(.progress)
        loginWorker.loginAndRegister(type: type, in: self) { [weak self] token, error in
            if token != nil && error == nil {
                self?.logIn()
            } else {
                self?.handleFailure(error: error)
            }
        }
    }
    
    @IBAction func tapTryDemoButton(_ sender: Any) {
        service.keyStorage.setToDemoUser()
        performSegue(type: .unwindToInitial, sender: self)
    }
    
    @IBAction func tapQRCode(_ sender: UIButton) {
        Statistics.log(event: .tapQRCodeLogin)
        service.router.showCodeCapture(in: self, delegate: self, type: .privateKey)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        if let vc = segue.source as? ApplicationFlowVC, let error = vc.error {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.handleFailure(error: error)
            }
        }
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
        
        controller.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] action in
            guard let self = self else { return }
            
            service.keyStorage.deleteStoredKeys()
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
            animator.addAnimations {
                self.qrCodeButton.isHidden = !self.canLogWithQRCode
            }
            animator.startAnimation()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        Vibrator().lightVibes()
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
        logIn()
    }
    
    private func logIn() {
        HUD.hide()
        performSegue(type: .unwindToInitial)
    }
    
    @objc
    private func dynamicLinkReceived() {
        navigationController?.popToViewController(self, animated: false)
        performSegue(type: .welcome)
    }
}

// MARK: CodeCaptureDelegate
extension LoginBlueVC: CodeCaptureDelegate {
    func codeCapture(controller: CodeCaptureVC, didCapture: String, type: QRCodeType) {
        switch type {
        case .bitcoinWiF:
            controller.close(cancelled: false)
            Session.newPrivateKeySet(privateKey: didCapture)
            self.performSegue(withIdentifier: "unwindToInitial", sender: self)
        case .surillaLink,
             .teambrellaLink:
            log("Is teambrella! \(didCapture)", type: .info)
            guard canLogWithQRCode else {
                log("Private key already exists. Universal link transition is cancelled", type: .info)
                return
            }
            guard let url = URL(string: didCapture) else { return }
            
            controller.close(cancelled: false)
            SimpleStorage().store(bool: true, forKey: .isRegistering)
            let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            activity.webpageURL = url
            let application = UIApplication.shared
            let delegate = application.delegate
            _ = delegate?.application?(application, continue: activity, restorationHandler: { item in
                
            })
        default:
            log("Wrong type: \(type), \(didCapture)", type: .info)
        }
    }
    
    func codeCaptureWillClose(controller: CodeCaptureVC, cancelled: Bool) {
        
    }
}
