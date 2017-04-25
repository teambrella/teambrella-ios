//
//  BlockchainInput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class BlockchainInput: NSManagedObject {
    var previousTransactionIndex: Int { return Int(previousTransactionIndexValue) }
    var ammount: Decimal { return ammountValue! as Decimal }
    var id: String { return idValue! }
    var previousTransactionID: String? { return previousTransactionIDValue }
    var transactionID: String { return transactionIDValue! }
}
