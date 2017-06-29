//
//  MeVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 14.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MeVC: ButtonBarPagerTabStripViewController, TabRoutable {
    let tabType: TabType = .me
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.me".localized
        tabBarItem.title = "Main.me".localized
    }
    
    override func viewDidLoad() {
        setupTeambrellaTabLayout()
        super.viewDidLoad()
        setupTransparentNavigationBar()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let my = UIStoryboard(name: "Me",
                              bundle: nil).instantiateViewController(withIdentifier: "CoverageVC")
        let proxyFor = UIStoryboard(name: "Me",
                                    bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")
        let index = UIStoryboard(name: "Me",
                                 bundle: nil).instantiateViewController(withIdentifier: "WalletVC")
        return [my, proxyFor, index]
    }
    
}
