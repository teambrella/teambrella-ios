//  InitialVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.

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
import UIKit

final class InitialVC: UIViewController {
    enum InitialVCMode {
        case idle
        case login
        case demoExpired
    }
    
    enum Constant {
        static let getTeamsAttempts = 3
    }
    
    let loginWorker: LoginWorker = LoginWorker()
    var mode: InitialVCMode = .login
    weak var sod: SODVC?
    weak var loginBlueVC: LoginBlueVC?
    
    var isFirstLoad: Bool = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let state = UIApplication.shared.applicationState
        log("Application state is: \(state.rawValue)", type: .info)
        guard state != .background else {
            log("Running in background", type: .info)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(performTransitionsAfterWakeUp),
                                                   name: UIApplication.didBecomeActiveNotification,
                                                   object: nil)
            return
        }
        
        performTransitions()
    }
    
    func login(teamID: Int?) {
        loginBlueVC?.dismiss(animated: false, completion: nil)
        if service.keyStorage.hasRealPrivateKey {
            service.keyStorage.setToRealUser()
            getTeams()
        }
    }
    
    @objc
    func performTransitionsAfterWakeUp() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        performTransitions()
    }
    
    func performTransitions() {
        if isFirstLoad, service.keyStorage.isUserSelected {
            mode = .idle
            getTeams()
        } else {
            switch mode {
            case .login:
                performSegue(type: .login)
            case .demoExpired:
                let router = service.router
                if let vc = SODManager(router: router).showOutdatedDemo(in: self) {
                    vc.upperButton.addTarget(self, action: #selector(tapDemo), for: .touchUpInside)
                    vc.lowerButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
                    sod = vc
                }
            default:
                break
            }
            
            mode = .idle
        }
        isFirstLoad = false
    }
    
    // MARK: Callbacks
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        //        if segue.source is ApplicationFlowVC {
        //            performSegue(withIdentifier: "application", sender: self)
        //        } else {
        mode = .idle
        getTeams()
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        HUD.hide()
        if segue.type == .teambrella {
            
        }
        if let nc = segue.destination as? UINavigationController,
            let vc = nc.viewControllers.first as? LoginBlueVC {
            vc.loginWorker = loginWorker
            loginBlueVC = vc
        }
    }
    
    @objc
    private func tapDemo() {
        service.keyStorage.setToDemoUser()
        getTeams()
        sod?.dismiss(animated: true) {
            
        }
    }
    
    @objc
    private func tapBack() {
        sod?.dismiss(animated: true) {
            self.performSegue(type: .login)
        }
    }
    
    // MARK: Private
    
    private func getTeams() {
        signInAttemptsRemaining -= 1
        HUD.show(.progress)
        loginWorker.getTeams(completion: { [weak self] teamsModel, isDemo in
            self?.startSession(teamsEntity: teamsModel, isDemo: isDemo)
        }) { [weak self] error in
            self?.failure(error: error)
        }
    }
    
    private func startSession(teamsEntity: TeamsModel, isDemo: Bool) {
        signInAttemptsRemaining = Constant.getTeamsAttempts
        service.router.startNewSession(isDemo: isDemo, teamsModel: teamsEntity)
        
        if !isDemo {
            Statistics.register(userID: teamsEntity.userID)
            SimpleStorage().store(bool: true, forKey: .didLogWithKey)
        }
        
        service.teambrella.startUpdating(completion: { result in
            let description = result.rawValue == 0 ? "new data" : result.rawValue == 1 ? "no data" : "failed"
            log("Teambrella service get updates results: \(description)", type: .info)
        })
        
        HUD.hide()
        presentMasterTab()
        requestPush()
    }
    
    private func failure(error: Error) {
        log("InitialVC got error: \(error)", type: .error)
        HUD.hide()
        switch error {
        case let error as TeambrellaError:
            switch error.kind {
            case .brokenSignature:
                if retryGettingTeams() {
                    return
                } else {
                    service.keyStorage.clearLastUserType()
                    SimpleStorage().store(bool: true, forKey: .isRegistering)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.loginBlueVC?.tapNextButton()
                    }
                }
            default:
                break
            }
        default:
            break
        }
        service.router.logout()
        SimpleStorage().store(bool: false, forKey: .didLogWithKey)
        performSegue(type: .login)
    }
    
    var signInAttemptsRemaining = Constant.getTeamsAttempts
    
    func retryGettingTeams() -> Bool {
        if signInAttemptsRemaining > 0 {
            getTeams()
            return true
        }
        return false
    }
    
    private func presentMasterTab() {
        performSegue(type: .teambrella)
        if service.dao.recentScene == .feed {
            service.router.switchToFeed()
        } else {
            // present default .home screen
        }
    }
    
    private func requestPush() {
        let application = UIApplication.shared
        service.push.askPermissionsForRemoteNotifications(application: application)
    }
    
}
