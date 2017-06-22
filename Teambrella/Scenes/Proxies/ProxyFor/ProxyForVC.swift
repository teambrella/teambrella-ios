//
//  ProxyForVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProxyForVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ProxyForVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Proxy.ProxyForVC.indicatorTitle".localized)
    }
}
