//
//  TeamRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

final class TeamRouter {
    func presentChat(context: ChatContext) {
        guard let vc = UniversalChatVC.instantiate() as? UniversalChatVC else { fatalError("Error instantiating") }
        
        vc.setContext(context: context)
        service.router.push(vc: vc)
    }
    
    func presentClaim(claim: ClaimLike) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        vc.claimID = claim.id
        service.router.push(vc: vc)
    }
    
    func presentClaim(claimID: String) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        vc.claimID = claimID
        service.router.push(vc: vc)
    }
    
    func showChooseTeam(in viewController: UIViewController) {
        //delegate: ChooseYourTeamControllerDelegate
            guard let vc = ChooseYourTeamVC.instantiate()
                as? ChooseYourTeamVC else { fatalError("Error instantiating") }
            
            //vc.delegate = delegate
            viewController.present(vc, animated: false, completion: nil)
    }
}
