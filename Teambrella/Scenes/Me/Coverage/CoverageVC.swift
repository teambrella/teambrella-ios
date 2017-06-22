//
//  CoverageVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class CoverageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension CoverageVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Me.CoverageVC.indicatorTitle".localized)
    }
}
