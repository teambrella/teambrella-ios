//
//  MeRouter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

final class MeRouter {
    func presentWalletDetails() {
        guard let vc = WalletDetailsVC.instantiate() as? WalletDetailsVC else { fatalError("Error instantiating") }
        service.router.push(vc: vc)
    }
    
}
