//
//  TxOutput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class TxOutput: NSManagedObject {
    /// amount in Bitcoins
    var amount: Decimal { return amountValue! as Decimal }
    var id: String { return idValue! }
//    var payToID: String { return payToIDValue! }
//    var transactionID: String { return transactionIDValue! }
}
