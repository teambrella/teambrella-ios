//
//  UserIndexCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct UserIndexCellModel {
    let avatarString: String
    let name: String
    let city: String
    let amount: Double
    
}

extension UserIndexCellModel {
    static func fake() -> UserIndexCellModel {
        return UserIndexCellModel(avatarString: "",
                                  name: "Fake",
                                  city: "Fakeville",
                                  amount: 13.45)
    }
}
