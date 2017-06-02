//
//  MembersRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

final class MembersRouter {
    func presentMemberProfile(teammate: TeammateLike) {
        guard let vc = TeammateProfileVC.instantiate() as? TeammateProfileVC else { fatalError("Error instantiating") }
        vc.teammate = teammate
        service.router.push(vc: vc)
    }
    
}
