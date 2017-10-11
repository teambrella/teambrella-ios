//
//  TeamVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

class TeamVC: ButtonBarPagerTabStripViewController, TabRoutable {
    let tabType: TabType = .team
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.team".localized
        tabBarItem.title = "Main.team".localized
    }
    
    override func viewDidLoad() {
        setupTeambrellaTabLayout()
        super.viewDidLoad()
        setupTransparentNavigationBar()
        navigationItem.title = service.session?.currentTeam?.teamName ?? "Main.team".localized
    }
    
    func tapTeam(button: UIButton) {
        service.router.showJoinTeam(in: self)
    }
    
    func teamSelected(name: String?) {
        let name = name ?? ""
        let alert = UIAlertController(title: "Team change",
                                      message: "Are you sure you want to change your current team to \(name)?",
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes I do", style: .destructive) { action in
            log("Confirm pressed", type: .userInteraction)
        }
        alert.addAction(confirm)
        let cancel = UIAlertAction(title: "No chance", style: .cancel) { action in
            log("Cancel pressed", type: .userInteraction)
        }
        alert.addAction(cancel)
        present(alert, animated: true) {
            log("Alert presented", type: .userInteraction)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let feed = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        let members = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "MembersVC")
        let claims = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "ClaimsVC")
        //let rules = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "RulesVC")
        return [feed, members, claims /* , rules */]
    }
    
}
