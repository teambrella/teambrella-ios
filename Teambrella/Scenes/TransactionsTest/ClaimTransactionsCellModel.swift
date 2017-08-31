//
//  ClaimTransactionCellModel.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ClaimTransactionsCellModel {
    let txID: String
    let userID: String
    let avatarString: String
    let name: String
    let amountCrypto: Double
    let amountFiat: Double
    let status: Int
    
    init(json: JSON) {
        txID = json["TxId"].stringValue
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        name = json["Name"].stringValue
        amountCrypto = json["AmountBtc"].doubleValue
        amountFiat = json["AmountFiat"].doubleValue
        status = json["Status"].intValue
    }
}
