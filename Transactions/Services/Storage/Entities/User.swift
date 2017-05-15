//
//  User.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

class User: NSManagedObject {
    struct Constant {
        static let tmpPrivateKey = "93ProQDtA1PyttRz96fuUHKijV3v2NGnjPAxuzfDXwFbbLBYbxx"
    }
    
    var id: Int {
        return Int(idValue)
    }
    var privateKey: String {
        return privateKeyValue!
    }
    var auxWalletAmount: Decimal {
        return auxWalletAmountValue as! Decimal
    }
    var auxWalletChecked: Date? {
        return auxWalletCheckedValue as Date?
    }
    
    var bitcoinPrivateKey: Key {
        let key = Key(base58String: privateKey, timestamp: 0)
        return key
    }
}
