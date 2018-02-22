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
    
    var mode: InitialVCMode = .login
    weak var sod: SODVC?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if service.keyStorage.isUserSelected {
            mode = .idle
            startLoadingTeams()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // MARK: Callbacks
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        startLoadingTeams()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        HUD.hide()
        if segue.type == .teambrella {
            
        }
    }
    
    @objc
    private func tapDemo() {
        service.keyStorage.clearLastUserType()
        self.startLoadingTeams()
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
    
    private func getTeams(timestamp: Int64) {
        service.keyStorage.timestamp = timestamp
        let isDemo = service.keyStorage.isDemoUser
        service.dao.requestTeams(demo: isDemo).observe { [weak self] result in
            switch result {
            case let .value(teamsEntity):
                self?.startSession(teamsEntity: teamsEntity, isDemo: isDemo)
            case .temporaryValue:
                break
            case .error:
                self?.failure()
            }
        }
    }
    
    private func startSession(teamsEntity: TeamsModel, isDemo: Bool) {
        service.session = Session(isDemo: isDemo)
        service.teambrella.startUpdating(completion: { result in
            let description = result.rawValue == 0 ? "new data" : result.rawValue == 1 ? "no data" : "failed"
            log("Teambrella service get updates results: \(description)", type: .info)
        })
        
        /*
         Selecting team that was used last time
         
         Firstly we try to use teamID that comes from server (but it is not implemented yet)
         Secondly we use a stored on device last used teamID
         and lastly if everything fails we take the first team from the list
         */
        let lastTeamID: Int
        if let receivedID = teamsEntity.lastTeamID {
            lastTeamID = receivedID
        } else if let storedID = SimpleStorage().int(forKey: .teamID) {
            lastTeamID = storedID
        } else {
            lastTeamID = teamsEntity.teams.first?.teamID ?? 0
        }
        var currentTeam: TeamEntity?
        for team in teamsEntity.teams where team.teamID == lastTeamID {
            currentTeam = team
            break
        }
        service.session?.currentTeam = currentTeam ?? teamsEntity.teams.first
        
        service.session?.teams = teamsEntity.teams
        service.session?.currentUserID = teamsEntity.userID
        let socket = SocketService()
        service.socket = socket
        service.teambrella.signToSockets(service: socket)
        SimpleStorage().store(bool: true, forKey: .didLogWithKey)
        HUD.hide()
        presentMasterTab()
        requestPush()
    }
    
    private func failure() {
        HUD.hide()
        service.router.logout()
        SimpleStorage().store(bool: false, forKey: .didLogWithKey)
        performSegue(type: .login)
    }
    
    private func startLoadingTeams() {
        HUD.show(.progress)
        service.server.updateTimestamp { timestamp, error in
            self.getTeams(timestamp: timestamp)
        }
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
