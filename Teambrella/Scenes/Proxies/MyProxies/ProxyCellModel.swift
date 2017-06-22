//
//  ProxyCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ProxyCellModel {
    let avatarString: String?
    let name: String
    let address: String
    let time: Date?
    let decisionsCoeff: Double
    let discussionCoeff: Double
    let frequencyCoeff: Double

}

extension ProxyCellModel {
    static func fake(name: String) -> ProxyCellModel {
    return ProxyCellModel(avatarString: nil,
                          name: name,
                          address: "Bruxelles",
                          time: Date(),
                          decisionsCoeff: 0.1,
                          discussionCoeff: 0.2,
                          frequencyCoeff: 0.5)
    }
}
