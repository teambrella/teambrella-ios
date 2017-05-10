//
//  User.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class User {
    var id: Int = 0
    var privateKey: String = ""
    var auxWalletAmount: Decimal = 0
    var auxWalletChecked: Date?
    
    var bitcoinPrivateKey: Key? {
        let key = Key(base58String: privateKey, timestamp: 0)
        return key
    }
}
