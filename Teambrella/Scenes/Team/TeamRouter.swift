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
        guard let vc = ChatVC.instantiate() as? ChatVC else { fatalError("Error instantiating") }
        vc.createDataSource(topic: topic)
        service.router.push(vc: vc)
    }
}
