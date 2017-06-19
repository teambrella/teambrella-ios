//
//  TeamRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

final class TeamRouter {
    func presentChat(teammate: TeammateLike) {
        guard let topic = teammate.extended?.topic else { return }
        
        presentChat(topic: topic)
    }
    
    func presentChat(topic: Topic) {
        guard let vc = UniversalChatVC.instantiate() as? UniversalChatVC else { fatalError("Error instantiating") }
        
        //vc.createDataSource(topic: topic)
        service.router.push(vc: vc)
    }
    
    func presentClaim(claim: ClaimLike) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        //vc.claim = claim
        vc.claimID = claim.id
        service.router.push(vc: vc)
    }
    
    func presentClaim(claimID: String) {
        guard let vc = ClaimVC.instantiate() as? ClaimVC else { fatalError("Error instantiating") }
        
        vc.claimID = claimID
        service.router.push(vc: vc)
    }
}
