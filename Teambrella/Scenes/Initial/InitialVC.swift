//
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

class InitialVC: UIViewController {
    var isLoginNeeded: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Instantly move to product version
        //performSegue(type: .teambrella)
        //getTeams()
        
        if let address = Keychain.value(forKey: .ethPrivateAddress),
            let keyType = ServerService.FakeKeyType(rawValue: address) {
            ServerService.currentKeyType = keyType
            isLoginNeeded = false
            startLoadingTeams()
        }
    }
    
    func getTeams() {
        service.storage.setLanguage().observe { [weak self] resultLang in
            guard case .value = resultLang else {
                 self?.failure()
                return
            }
            
            service.storage.requestTeams().observe { [weak self] result in
                switch result {
                case let .value(teamsEntity):
                    service.session = Session()
                    let lastTeam = teamsEntity.lastTeamID.map { id in
                        teamsEntity.teams.filter { team in team.teamID == id }
                    }?.first
                    
                    if let lastTeam = lastTeam {
                        service.session?.currentTeam = lastTeam
                    } else if !teamsEntity.teams.isEmpty {
                        service.session?.currentTeam = teamsEntity.teams.first
                    }
                    service.session?.teams = teamsEntity.teams
                    service.session?.currentUserID = teamsEntity.userID
                    self?.performSegue(type: .teambrella)
                case .error:
                    break
                }
            }
        }
    }
    
    func failure() {
        HUD.hide()
        service.router.logout()
        performSegue(type: .login)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoginNeeded {
            performSegue(type: .login)
            isLoginNeeded = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        HUD.hide()
        if segue.type == .main {
            if let tabVc = segue.destination as? UITabBarController,
                let nc = tabVc.viewControllers?.first as? UINavigationController,
                let first = nc.viewControllers.first as? TransactionsVC {
                first.teambrella = service.teambrella
            }
        }
    }
    
    func startLoadingTeams() {
        HUD.show(.progress)
        getTeams()
    }
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        startLoadingTeams()
    }
    
    @IBAction func tapTeambrella(_ sender: Any) {
        performSegue(type: .teambrella)
    }
    
    @IBAction func tapTests(_ sender: Any) {
        let me = service.teambrella.fetcher.user
        if me.isFbAuthorized {
            performSegue(type: .main)
        } else {
            performSegue(type: .login)
        }
    }
    
}
