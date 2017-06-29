//
//  InitialVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Instantly move to product version
        //performSegue(type: .teambrella)
        getTeams()
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
                                                               let recentTeamID) = response {
                                                    print("Teams: \(teams)")
                                                    print("Potential Teams: \(potentialTeams)")
                                                    print("Recent: \(String(describing: recentTeamID))")
                                                    if !teams.isEmpty {
                                                        service.session.currentTeam = teams.first
                                                        self?.performSegue(type: .teambrella)
                                                    }
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
        if segue.type == .main {
            if let tabVc = segue.destination as? UITabBarController,
                let nc = tabVc.viewControllers?.first as? UINavigationController,
                let first = nc.viewControllers.first as? TransactionsVC {
                first.teambrella = service.teambrella
            }
        }
    }
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        service.teambrella.fetcher.user.isFbAuthorized = true
        service.teambrella.fetcher.save()
        performSegue(type: .main)
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
