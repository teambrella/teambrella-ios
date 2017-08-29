//
//  ProxiesVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 14.06.17.

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

import UIKit
import XLPagerTabStrip

class ProxiesVC: ButtonBarPagerTabStripViewController, TabRoutable {
    let tabType: TabType = .proxy
    
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
