//
//  ProxiesVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 14.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProxiesVC: ButtonBarPagerTabStripViewController {
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.proxies".localized
        tabBarItem.title = "Main.proxies".localized
    }
    
    override func viewDidLoad() {
        setupTeambrellaTabLayout()
        super.viewDidLoad()
        setupTransparentNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let feed = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        let members = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "MembersVC")
        let claims = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "ClaimsVC")
        let rules = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "RulesVC")
        return [feed, members, claims, rules]
    }
    
}
