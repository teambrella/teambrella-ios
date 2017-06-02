//
//  LoginDetailsConfigurator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class LoginDetailsConfigurator {
    weak var vc: LoginDetailsVC?
    
    init(vc: LoginDetailsVC, fbUser: FacebookUser) {
        self.vc = vc
        let router = LoginDetailsRouterImpl(vc: vc)
        let presenter = LoginDetailsPresenterImpl(user: fbUser, router: router)
        presenter.view = vc as LoginDetailsView
        vc.presenter = presenter
    }
    
}
