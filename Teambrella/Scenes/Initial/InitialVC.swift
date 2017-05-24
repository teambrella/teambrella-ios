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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let me = teambrella.fetcher.user
        if me.isFbAuthorized {
            performSegue(type: .main)
        } else {
            performSegue(type: .login)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.type)
        print(type(of: segue.destination))
        if segue.type == .main {
            if let tabVc = segue.destination as? UITabBarController,
                let nc = tabVc.viewControllers?.first as? UINavigationController,
                let first = nc.viewControllers.first as? TransactionsVC {
                first.teambrella = teambrella
            }
        }
    }
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        var me = teambrella.fetcher.user
        me.isFbAuthorized = true
        teambrella.fetcher.save()
        performSegue(type: .main)
    }
    
}
