//
//  ProxyForCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ProxyForCellModel {
    let avatarString: String
    let name: String
    let lastVoted: Date
    let amount: Double
    
}

extension ProxyForCellModel {
    static func fake() -> ProxyForCellModel {
        return ProxyForCellModel(avatarString: "",
                                 name: "Fake Name",
                                 lastVoted: Date(),
                                 amount: 13)
    }
}
