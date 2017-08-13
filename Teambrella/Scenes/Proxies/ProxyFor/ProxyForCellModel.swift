//
//  ProxyForCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ProxyForCellModel {
    let userID: String
    let avatarString: String
    let name: String
    let lastVoted: Date?
    let amount: Double // commission?
 
    init(json: JSON) {
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        name = json["Name"].stringValue
        lastVoted = Formatter.teambrella.date(from: json["LastVoted"].stringValue)
        amount = json["Commission"].doubleValue
    }
}
