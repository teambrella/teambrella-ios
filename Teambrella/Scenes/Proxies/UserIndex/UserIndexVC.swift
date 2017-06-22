//
//  UserIndexVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class UserIndexVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension UserIndexVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Proxy.UserIndexVC.indicatorTitle".localized)
    }
}
