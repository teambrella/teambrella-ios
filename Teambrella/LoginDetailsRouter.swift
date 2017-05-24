//
//  LoginDetailsRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol LoginDetailsRouter {
    func validate()
}

class LoginDetailsRouterImpl: LoginDetailsRouter {
    weak var vc: LoginDetailsVC?
    
    init(vc: LoginDetailsVC) {
        self.vc = vc
    }
    
    func validate() {
        vc?.performSegue(type: .unwindToInitial)
    }
}
