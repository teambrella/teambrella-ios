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
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let my = UIStoryboard(name: "Proxies",
                              bundle: nil).instantiateViewController(withIdentifier: "MyProxiesVC")
        let proxyFor = UIStoryboard(name: "Proxies",
                                    bundle: nil).instantiateViewController(withIdentifier: "ProxyForVC")
        let index = UIStoryboard(name: "Proxies",
                                 bundle: nil).instantiateViewController(withIdentifier: "UserIndexVC")
        return [my, proxyFor, index]
    }
    
}
