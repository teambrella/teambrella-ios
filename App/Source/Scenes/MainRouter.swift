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
    
    var frontmostViewController: UIViewController? {
        return topViewController()
    }
    
    private func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController)
        -> UIViewController? {
            if let nav = base as? UINavigationController {
                return topViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topViewController(base: selected)
                }
            }
            if let presented = base?.presentedViewController {
                return topViewController(base: presented)
            }
            return base
    }
    
    func push(vc: UIViewController, animated: Bool = true) {
        navigator?.pushViewController(vc, animated: animated)
    }
    
    func popToBase(animated: Bool = false) {
        guard let navigator = navigator else { return }
        guard let tabController = masterTabBar else { return }
        
        navigator.popToViewController(tabController, animated: animated)
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
        masterTabBar?.setLastTabImage(image: image)
    }
    
    // MARK: Switch
    
    func switchToWallet() {
        if let vc = switchTab(to: .me) as? ButtonBarPagerTabStripViewController {
            vc.moveToViewController(at: 2, animated: false)
        }
    }
    
    func switchToCoverage() {
        if let vc = switchTab(to: .me) as? ButtonBarPagerTabStripViewController {
            vc.moveToViewController(at: 1, animated: false)
        }
    }
    
    func switchToFeed() {
        if let vc = switchTab(to: .team) as? ButtonBarPagerTabStripViewController {
            vc.moveToViewController(at: 0, animated: false)
        }
    }
    
    // MARK: Push
    
    func presentJoinTeam(animated: Bool = true) {
        guard let vc = JoinTeamVC.instantiate() as? JoinTeamVC else { fatalError("Error instantiating") }
        
        push(vc: vc, animated: animated)
    }
    
    func presentChat(context: ChatContext, itemType: ItemType, animated: Bool = true) {
        let last = navigator?.viewControllers.last
        guard last as? UniversalChatVC == nil else {
            log("already opened chat", type: [.error, .info])
            return
        }
        guard let vc = UniversalChatVC.instantiate() as? UniversalChatVC else { fatalError("Error instantiating") }
        
        vc.session = service.session
        vc.router = self
        vc.push = service.push
        vc.socket = service.socket
        vc.setContext(context: context, itemType: itemType)
        push(vc: vc, animated: animated)
    }
    
    func presentClaim(claim: ClaimEntity, animated: Bool = true) {
        guard let vc = getControllerClaim(claimID: claim.id) else { fatalError("Error instantiating") }
        
        push(vc: vc, animated: animated)
    }
    
    func presentClaim(claimID: Int, scrollToVoting: Bool = false, animated: Bool = true) {
        guard let vc = getControllerClaim(claimID: claimID) else { fatalError("Error instantiating") }
        
        vc.claimID = claimID
        vc.isScrollToVoteNeeded = scrollToVoting
        push(vc: vc, animated: animated)
    }
    
    func presentOthersVoted(teamID: Int, teammateID: Int?, claimID: Int?) {
        guard let vc = OthersVotedVC.instantiate() as? OthersVotedVC else { return }
        
        vc.router = self
        vc.teamID = teamID
        vc.teammateID = teammateID
        vc.claimID = claimID
        push(vc: vc, animated: true)
    }
    
    func getControllerClaim(claimID: Int) -> ClaimVC? {
        let vc = ClaimVC.instantiate() as? ClaimVC
        
        vc?.router = self
        vc?.session = service.session
        vc?.claimID = claimID
        return vc
    }
    
    func getControllerMemberProfile(teammateID: String) -> TeammateProfileVC? {
        let vc = TeammateProfileVC.instantiate() as? TeammateProfileVC
        
        vc?.teammateID = teammateID
//        vc?.currentUserID = service.session?.currentUserID
//        vc?.router = self
//        vc?.session = service.session
//        vc?.currencyName = service.currencyName
        return vc
    }
    
    func presentMemberProfile(teammateID: String, scrollToVote: Bool = false, animated: Bool = true) {
        guard let vc = getControllerMemberProfile(teammateID: teammateID) else { fatalError("Error instantiating") }
        
        vc.scrollToVote = scrollToVote
        push(vc: vc, animated: animated)
    }
    
    func presentClaims(teammateID: Int? = nil, animated: Bool = true) {
        guard let vc = ClaimsVC.instantiate() as? ClaimsVC else { fatalError("Error instantiating") }
        
//        vc.router = self
        vc.teammateID = teammateID
        vc.isPresentedInStack = true
        push(vc: vc, animated: animated)
    }
    
    func presentClaimTransactionsList(teamID: Int, claimID: Int, userID: String) {
        guard let vc = ClaimTransactionsVC.instantiate() as? ClaimTransactionsVC
            else { fatalError("Error instantiating") }
        
        vc.router = self
        vc.teamID = teamID
        vc.claimID = claimID
        vc.userID = userID
        push(vc: vc)
    }
    
    func presentWalletTransactionsList(teamID: Int, balance: Ether?, reserved: Ether?) {
        guard let vc = WalletTransactionsVC.instantiate() as? WalletTransactionsVC
            else { fatalError("Error instantiating") }
        
        vc.teamID = teamID
        vc.balance = balance.map { MEth($0) }
        vc.reserved = reserved
        vc.router = self
        push(vc: vc)
    }
    
    func presentWalletCosignersList(cosigners: [CosignerEntity]) {
        guard let vc = WalletCosignersVC.instantiate() as? WalletCosignersVC
            else { fatalError("Error instantiating") }
        
        vc.router = self
        vc.cosigners = cosigners
        push(vc: vc)
    }
    
    func presentWalletDetails(walletID: String, animated: Bool = true) {
        guard let vc = WalletDetailsVC.instantiate() as? WalletDetailsVC else { fatalError("Error instantiating") }
        
        vc.walletID = walletID
        push(vc: vc, animated: animated)
    }
    
    func presentWithdraw(balance: MEth, reserved: Ether, animated: Bool = true) {
        guard let vc = WithdrawVC.instantiate() as? WithdrawVC else { fatalError("Error instantiating") }
        
        vc.session = service.session
        vc.router = self
        vc.setupCrypto(balance: balance, reserved: reserved)
        push(vc: vc, animated: animated)
    }
    
    func presentReport(context: ReportContext,
                       in parentViewController: UIViewController? = nil,
                       delegate: ReportDelegate?) {
        guard let vc = ReportVC.instantiate() as? ReportVC else { fatalError("Error instantiating") }
        
        vc.reportContext = context
        vc.delegate = delegate
        guard let parentViewController = parentViewController else {
            service.router.push(vc: vc)
            return
        }
        
        vc.isModal = true
        parentViewController.present(vc, animated: true) {
            
        }
    }
    
    func presentPrivateMessages(animated: Bool = true) {
        guard let vc = PrivateMessagesVC.instantiate() as? PrivateMessagesVC else { fatalError("Error instantiating") }
        
        vc.router = self
        push(vc: vc, animated: animated)
    }
    
    func presentCompareTeamRisk(ranges: [RiskScaleRange]) {
        guard let vc = CompareTeamRiskVC.instantiate() as? CompareTeamRiskVC else { fatalError("Error instantiating") }
        
        vc.ranges = ranges
        vc.router = self
        push(vc: vc)
    }
    
    func presentConsole() {
        guard let vc = Console.instantiate() as? Console else { fatalError("Error instantiating") }
        
        vc.push = service.push
        vc.teambrella = service.teambrella
        push(vc: vc)
    }
    
    // MARK: Present Modally
    
    func showChooseTeam(in viewController: UIViewController, delegate: ChooseYourTeamControllerDelegate) {
        //delegate: ChooseYourTeamControllerDelegate
        guard let vc = ChooseYourTeamVC.instantiate()
            as? ChooseYourTeamVC else { fatalError("Error instantiating") }
        
        vc.delegate = delegate
        vc.router = self
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
    
    func showNotificationFilter(in viewController: UIViewController,
                                delegate: MuteControllerDelegate,
                                currentState type: TopicMuteType) {
        guard let vc = MuteVC.instantiate() as? MuteVC else { fatalError("Error instantiating") }
        
        vc.delegate = delegate
        vc.type = type
        viewController.present(vc, animated: false, completion: nil)
    }
    
    func showWithdrawInfo(in viewController: UIViewController,
                          balance: Ether,
                          reserved: Ether) {
        guard let vc = WithdrawInfoVC.instantiate() as? WithdrawInfoVC else { fatalError("Error instantiating") }
        
        // vc.delegate = delegate
        vc.cryptoBalance = balance
        vc.cryptoReserved = reserved
        viewController.present(vc, animated: false, completion: nil)
    }
    
    func showWalletQRCode(in viewController: UIViewController) {
        guard let vc = WalletQRCodeVC.instantiate() as? WalletQRCodeVC else { fatalError("Error instantiating") }
        
        vc.privateKey = service.keyStorage.privateKey
        viewController.present(vc, animated: true, completion: nil)
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
    
    // MARK: Other
    
    @discardableResult
    func logout() -> InitialVC? {
        guard let navigator = navigator else { return nil }
        
        PlistStorage().removeCache()
        service.session = nil
        service.keyStorage.clearLastUserType()
        navigator.clear()
        do {
            try
                service.teambrella.clear()
        } catch {
            log("\(error)", type: [.crypto, .error])
        }
        for vc in navigator.viewControllers {
            if let vc = vc as? InitialVC {
                navigator.popToViewController(vc, animated: true)
                vc.mode = .login
                return vc
            }
        }
        return nil
    }
    
    func switchTeam() {
        let initial = navigator?.viewControllers.filter { $0 is InitialVC }.first
        if let initial = initial {
            navigator?.popToViewController(initial, animated: false)
            initial.performSegue(type: .teambrella)
        }
        
    }
    
    func manageBrokenSignature() {
        if let vc = logout() {
            vc.mode = .demoExpired
        }
    }
    
    @discardableResult
    func showSOD(mode: SODVC.SODMode = .outdated, in controller: UIViewController) -> SODVC? {
        guard let vc = SODVC.instantiate() as? SODVC else { return nil }
        
        vc.mode = mode
        vc.loadViewIfNeeded()
        controller.present(vc, animated: true)
        return vc
    }

    @discardableResult
    func showCodeCapture(in controller: UIViewController,
                         delegate: CodeCaptureDelegate,
                         type: CodeCaptureVC.LayoutType = .ethereum) -> CodeCaptureVC? {
        guard let vc = CodeCaptureVC.instantiate() as? CodeCaptureVC else { return nil }

        vc.type = type
        vc.delegate = delegate
        controller.present(vc, animated: true)
        return vc
    }
    
}
