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
    var id: Int {
        return Int(idValue)
    }
    var privateKey: String {
        return privateKeyValue!
    }
    var auxWalletAmount: Decimal {
        return auxWalletAmountValue! as Decimal
    }
    var auxWalletChecked: Date? {
        return auxWalletCheckedValue as Date?
    }
    
    var isFbAuthorized: Bool {
        get {
            return isFbAuthorizedValue
        }
        set {
            isFbAuthorizedValue = newValue
        }
    }
    
    var lastUpdated: Int64 {
        get {
            return lastUpdatedValue
        }
        set {
            let prev = lastUpdated
            print("last updated changed from \(prev)")
            print("last updated changed to \(newValue)")
            print("updates delta = \(Double(newValue - prev) / 10_000_000) seconds")
            lastUpdatedValue = newValue
            try? managedObjectContext?.save()
        }
    }
    
    func key(timestamp: Int64 = 0) -> Key {
        return Key(base58String: privateKey, timestamp: timestamp)
    }
}
