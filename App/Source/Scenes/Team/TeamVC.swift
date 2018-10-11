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
    
    @IBOutlet var topBarContainer: UIView!
    var topBarVC: TopBarVC!
    
    var notificationType: TeamNotificationsType = .never {
        didSet {
            updateImageForNotificationsButton(with: notificationType)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = "Main.team".localized
        tabBarItem.title = "Main.team".localized
    }
    
    override func viewDidLoad() {
        setupTeambrellaTabLayout()
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupTransparentNavigationBar()
        navigationItem.title = "" //service.session?.currentTeam?.teamName ?? "Main.team".localized
        addTopBar()
        updateNotificationsType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         loadHomeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.layer.zPosition = -1
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func addTopBar() {
        guard let session = service.session else { return }
        
        topBarVC = TopBarVC.show(in: self, in: topBarContainer)
        topBarVC.router = service.router
        topBarVC.session = session
        topBarVC.delegate = self
        
        topBarVC.notificationsButton.isHidden = false
        
        topBarVC.setup()
    }
    
    func loadHomeData() {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        
        service.dao.requestHome(teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(model):
                self?.topBarVC.setPrivateMessages(unreadCount: model.unreadCount)
            case let .error(error):
                log("\(error)", type: .error)
            }
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let feed = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "FeedVC")
        let members = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "MembersVC")
        let claims = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "ClaimsVC")
        //let rules = UIStoryboard(name: "Team", bundle: nil).instantiateViewController(withIdentifier: "RulesVC")
        return [feed, members, claims /* , rules */]
    }
    
    private func updateNotificationsType() {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        
        service.dao.requestSettings(current: notificationType, teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(settings):
                self?.notificationType = settings.type
            case let .error(error):
                log(error)
            }
        }
    }
    
    private func updateImageForNotificationsButton(with type: TeamNotificationsType) {
        let image: UIImage
        switch type {
        case .never:
            image = #imageLiteral(resourceName: "iconBellMuted1")
        default:
            image = #imageLiteral(resourceName: "iconBell1")
        }
        topBarVC.notificationsButton.setImage(image, for: .normal)
    }
    
}

extension TeamVC: TopBarDelegate {
    func topBar(vc: TopBarVC, didSwitchTeamToID: Int) {
        
    }
    
    func topBar(vc: TopBarVC, didTapNotifications: UIButton) {
        service.router.showTeamNotificationsSelector(in: self, delegate: self, currentState: notificationType)
    }
}

extension TeamVC: SelectorDelegate {
    func mute(controller: SelectorVC, didSelect index: Int) {
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        guard let selectedType = controller.dataSource.type(for: index) as? TeamNotificationsType  else {
            return
        }
        
        notificationType = selectedType
        service.dao.sendSettings(current: notificationType, teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(settings):
                self?.notificationType = settings.type
            case let .error(error):
                log(error)
            }
        }
    }
    
    func didCloseMuteController(controller: SelectorVC) {
        
    }
}
