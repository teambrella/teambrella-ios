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
        service.server.updateTimestamp { _ in
            let key = service.server.key
            let body = RequestBody(key: key, payload: [:])
            let request = TeambrellaRequest(type: .teams,
                                            parameters: nil,
                                            body: body,
                                            success: { [weak self] response in
                                                if case .teams(let teams,
                                                               let potentialTeams,
                                                               let userID,
                                                               let recentTeamID) = response {
                                                    print("Teams: \(teams)")
                                                    print("Potential Teams: \(potentialTeams)")
                                                    print("Recent: \(String(describing: recentTeamID))")
                                                    print("User id: \(userID)")
                                                    let lastTeam = recentTeamID.map { id in
                                                        return teams.filter { team in team.teamID == id } }?.first
                                                    if let lastTeam = lastTeam {
                                                        service.session.currentTeam = lastTeam
                                                    } else if !teams.isEmpty {
                                                        service.session.currentTeam = teams.first
                                                    }
                                                    service.session.teams = teams
                                                    service.session.currentUserID = userID
                                                    self?.performSegue(type: .teambrella)
                                                }
            }) { error in
                
            }
            request.start()
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
