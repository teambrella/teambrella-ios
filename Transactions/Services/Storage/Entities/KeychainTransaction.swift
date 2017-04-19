//
//  KeychainTransaction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class KeychainTransaction: NSManagedObject {
    var kind: TransactionKind? {
        return TransactionKind(rawValue: Int(rawKind))
    }
    var resolution: TransactionClientResolution? {
        return TransactionClientResolution(rawValue: Int(rawResolution))
    }
    var state: TransactionState? {
        return TransactionState(rawValue: Int(rawState))
    }
}
