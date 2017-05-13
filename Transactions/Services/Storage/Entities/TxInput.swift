//
//  TxInput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class TxInput: NSManagedObject {
    var previousTransactionIndex: Int { return Int(previousTransactionIndexValue) }
    var ammount: Decimal { return ammountValue! as Decimal }
    var id: UUID { return UUID(uuidString: idValue!)! }
    var previousTransactionID: String? { return previousTransactionIDValue }
    var transactionID: UUID { return UUID(uuidString: transactionIDValue!)! }
}
