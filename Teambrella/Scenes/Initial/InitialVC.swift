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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Instantly move to product version
        //performSegue(type: .teambrella)
        performSegue(type: .login)//getTeams()
    }
    
    func getTeams() {
        service.storage.setLanguage().observe { _ in
            service.storage.requestTeams().observe { [weak self] result in
                switch result {
                case let .value(teamsEntity):
                    let lastTeam = teamsEntity.lastTeamID.map { id in
                        return teamsEntity.teams.filter { team in team.teamID == id } }?.first
                    if let lastTeam = lastTeam {
                        service.session.currentTeam = lastTeam
                    } else if !teamsEntity.teams.isEmpty {
                        service.session.currentTeam = teamsEntity.teams.first
                    }
                    service.session.teams = teamsEntity.teams
                    service.session.currentUserID = teamsEntity.userID
                    self?.performSegue(type: .teambrella)
                case let .error(error):
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        //        service.teambrella.fetcher.user.isFbAuthorized = true
        //        service.teambrella.fetcher.save()
        //        performSegue(type: .main)
        HUD.show(.progress)
        getTeams()
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
