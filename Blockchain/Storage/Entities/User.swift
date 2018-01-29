//
//  User.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.05.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import CoreData
import Foundation

class User: NSManagedObject {
    var id: Int {
        return Int(idValue)
    }
    
    // stored in keychain
    var privateKey: String { return service.keyStorage.privateKey }
    
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
            let Δ = Double(newValue - prev) / 10_000_000
            log("last updated changed from \(prev) to \(newValue) delta = \(Δ) seconds", type: .cryptoDetails)
            lastUpdatedValue = newValue
            try? managedObjectContext?.save()
        }
    }
    
    func key(timestamp: Int64 = 0) -> Key {
        return Key(base58String: privateKey, timestamp: timestamp)
    }
}
