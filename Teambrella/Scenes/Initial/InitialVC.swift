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
    var isLoginNeeded: Bool = true
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if service.keyStorage.lastUserType != .none {
            isLoginNeeded = false
            startLoadingTeams()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoginNeeded {
            performSegue(type: .login)
            isLoginNeeded = false
        }
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
    
    // MARK: Private
    
    private func getTeams(timestamp: Int64) {
        service.keyStorage.timestamp = timestamp
        let isDemo = service.keyStorage.isDemoUser
        service.dao.requestTeams(demo: isDemo).observe { [weak self] result in
            switch result {
            case let .value(teamsEntity):
                self?.startSession(teamsEntity: teamsEntity)
            case .temporaryValue:
                break
            case .error:
                self?.failure()
            }
        }
    }
    
    private func startSession(teamsEntity: TeamsModel) {
        service.session = Session()
        
        service.teambrella.startUpdating()
        
        let lastTeam = teamsEntity.lastTeamID
            .map { id in teamsEntity.teams.filter { team in team.teamID == id } }?.first
        
        if let lastTeam = lastTeam {
            service.session?.currentTeam = lastTeam
        } else if !teamsEntity.teams.isEmpty {
            service.session?.currentTeam = teamsEntity.teams.first
        }
        service.session?.teams = teamsEntity.teams
        service.session?.currentUserID = teamsEntity.userID
        service.socket = SocketService()
        HUD.hide()
        presentMasterTab()
    }
    
    private func failure() {
        HUD.hide()
        service.router.logout()
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
    
}
