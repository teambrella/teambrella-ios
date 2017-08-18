//
//  MainRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.

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

/**
 To push new controller use 'present' methods
 To present controller modally use 'show' methods
 To switch between tabs use 'switch' methods
 */
final class MainRouter {
    let mainStoryboardName = "Main"
    
    var navigator: Navigator? {
        let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        let viewController = appDelegate?.window?.rootViewController as? Navigator
        return viewController
    }
    
    var masterTabBar: MasterTabBarController? {
        return navigator?.viewControllers.filter { $0 is MasterTabBarController }.first as? MasterTabBarController
    }
    
    private func push(vc: UIViewController, animated: Bool = true) {
        navigator?.pushViewController(vc, animated: animated)
    }
    
    private func switchTab(to tab: TabType) -> UIViewController? {
        return masterTabBar?.switchTo(tabType: tab)
    }
    
    func addRightNavigationButton(button: UIButton?) {
        guard let button = button else {
            navigator?.navigationItem.setRightBarButton(nil, animated: false)
            return
        }
        
        let barItem = UIBarButtonItem(customView: button)
        navigator?.navigationItem.setRightBarButton(barItem, animated: false)
    }
    
    func setMyTabImage(with image: UIImage) {
        if let vc = masterTabBar?.viewControllers?.last {
            vc.tabBarItem.image = ImageTransformer(image: image).tabBarImage
        }
    }
    
    // MARK: Switch
    
    func switchToWallet() {
        if let vc = switchTab(to: .me) as? ButtonBarPagerTabStripViewController {
            vc.moveToViewController(at: 2, animated: false)
        }
    }
    
    func switchToCoverage() {
        if let vc = switchTab(to: .me) as? ButtonBarPagerTabStripViewController {
            vc.moveToViewController(at: 0, animated: false)
        }
    }
    
    // MARK: Push
    
    func presentJoinTeam() {
        guard let vc = JoinTeamVC.instantiate() as? JoinTeamVC else { fatalError("Error instantiating") }
        
        push(vc: vc)
    }
    
    func presentChat(context: ChatContext) {
        guard let vc = UniversalChatVC.instantiate() as? UniversalChatVC else { fatalError("Error instantiating") }
        
        vc.setContext(context: context)
        push(vc: vc)
    }
    
    func presentClaim(claim: ClaimLike) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        vc.claimID = claim.id
        push(vc: vc)
    }
    
    func presentClaim(claimID: String) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        vc.claimID = claimID
        push(vc: vc)
    }
    
    func presentMemberProfile(teammate: TeammateLike) {
        guard let vc = TeammateProfileVC.instantiate() as? TeammateProfileVC else { fatalError("Error instantiating") }
        
        vc.teammate = teammate
        push(vc: vc)
    }
    
    func presentClaims(teammate: TeammateLike? = nil) {
        guard let vc = ClaimsVC.instantiate() as? ClaimsVC else { fatalError("Error instantiating") }
        
        vc.teammate = teammate
        vc.automaticallyAdjustsScrollViewInsets = false
        push(vc: vc)
    }
    
    func presentWalletDetails(walletID: String) {
        guard let vc = WalletDetailsVC.instantiate() as? WalletDetailsVC else { fatalError("Error instantiating") }
        
        vc.walletID = walletID
        push(vc: vc)
    }
    
    func presentReport(context: ReportContext, in parentViewController: UIViewController? = nil) {
        guard let vc = ReportVC.instantiate() as? ReportVC else { fatalError("Error instantiating") }
        
        vc.reportContext = context
        guard let parentViewController = parentViewController else {
            service.router.push(vc: vc)
            return
        }
        
        parentViewController.present(vc, animated: true) {
            
        }
    }
    
    // MARK: Present Modally
    
    func showChooseTeam(in viewController: UIViewController, delegate: ChooseYourTeamControllerDelegate) {
        //delegate: ChooseYourTeamControllerDelegate
        guard let vc = ChooseYourTeamVC.instantiate()
            as? ChooseYourTeamVC else { fatalError("Error instantiating") }
        
        vc.delegate = delegate
        viewController.present(vc, animated: false, completion: nil)
    }
    
    func showJoinTeam(in viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let vc = JoinTeamVC.instantiate() as? JoinTeamVC else { fatalError("Error instantiating") }
        // guard let vc = PoopyVC.instantiate() as? PoopyVC else { fatalError("Error instantiating") }
        
        viewController.present(vc, animated: true, completion: completion)
    }
    
    func showFilter(in viewController: UIViewController,
                    delegate: SortControllerDelegate,
                    currentSort type: SortVC.SortType) {
        guard let vc = SortVC.instantiate() as? SortVC else { fatalError("Error instantiating") }
        
        vc.delegate = delegate
        vc.type = type
        viewController.present(vc, animated: false, completion: nil)
    }
    
    /*
     func pushOrReuse(vc: UIViewController,
     animated: Bool = true,
     setup: ((_ vc: UIViewController, _ reuse: Bool) -> Void)?) {
     if let sameControllers = navigator?.viewControllers.filter({ type(of: $0) == type(of: vc) }),
     let reusableVC = sameControllers.last {
     setup?(reusableVC, true)
     navigator?.popToViewController(reusableVC, animated: animated)
     } else {
     setup?(vc, false)
     navigator?.pushViewController(vc, animated: animated)
     }
     }
     */
    
    func switchTeam() {
        let initial = navigator?.viewControllers.filter { $0 is InitialVC }.first
        if let initial = initial {
            navigator?.popToViewController(initial, animated: false)
            initial.performSegue(type: .teambrella)
        }
        
    }
    
    func applicationDidFinishLaunching(launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        //presentRootViewController(window: window)
        
        //        if let remoteNotification = RemoteNotification(launchOptions: launchOptions) {
        //            //Routing.notifications.handleRemoteNotification(remoteNotification)
        //        }
    }
    
}
