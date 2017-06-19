//
//  InitialVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    var teambrella: TeambrellaService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teambrella = TeambrellaService()
        // Instantly move to product version
        performSegue(type: .teambrella)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.type == .main {
            if let tabVc = segue.destination as? UITabBarController,
                let nc = tabVc.viewControllers?.first as? UINavigationController,
                let first = nc.viewControllers.first as? TransactionsVC {
                first.teambrella = teambrella
            }
        }
    }
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        teambrella.fetcher.user.isFbAuthorized = true
        teambrella.fetcher.save()
        performSegue(type: .main)
    }
    
    @IBAction func tapTeambrella(_ sender: Any) {
        performSegue(type: .teambrella)
    }
    
    @IBAction func tapTests(_ sender: Any) {
        let me = teambrella.fetcher.user
        if me.isFbAuthorized {
            performSegue(type: .main)
        } else {
            performSegue(type: .login)
        }
    }
    
}
