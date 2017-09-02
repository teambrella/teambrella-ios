//
//  WalletTransactionsCellModel.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 02.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WalletTransactionsCellModel {
    let claimID: Int
    let lastUpdated: Int
    let serverTxState: TransactionState
    let dateCreated: Date?
    let id: String
    let to: [WalletTransactionTo]
    
    init(json: JSON) {
        claimID = json["ClaimId"].intValue
        lastUpdated = json["LastUpdated"].intValue
        serverTxState = TransactionState(rawValue: json["ServerTxState"].intValue) ?? .created
        dateCreated = json["DateCreated"].stringValue.dateFromTeambrella
        id = json["Id"].stringValue
        to = json["To"].arrayValue.flatMap { WalletTransactionTo(json: $0) }
    }
}

struct WalletTransactionTo {
    let kind: TransactionKind
    let userID: String
    let name: String
    let amount: Double
    
    init(json: JSON) {
        kind = TransactionKind(rawValue: json["Kind"].intValue) ?? .payout
        userID = json["UserId"].stringValue
        name = json["UserName"].stringValue
        amount = json["Amount"].doubleValue
    }
}
