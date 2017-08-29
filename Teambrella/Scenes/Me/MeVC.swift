//
//  MeVC.swift
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
        let profile = UIStoryboard(name: "Team",
                                   bundle: nil).instantiateViewController(withIdentifier: "TeammateProfileVC")
//        let profile = UIStoryboard(name: "Me",
//                                    bundle: nil).instantiateViewController(withIdentifier: "ProfileVC")
        let coverage = UIStoryboard(name: "Me",
                              bundle: nil).instantiateViewController(withIdentifier: "CoverageVC")
        let wallet = UIStoryboard(name: "Me",
                                 bundle: nil).instantiateViewController(withIdentifier: "WalletVC")
        return [profile, coverage, wallet]
    }
    
}
