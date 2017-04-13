//
//  BitcoinTransactionInput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinTransactionInput {
    let id: UUID
    let transactionID: UUID
    let ammount: Decimal
    let previousTransactionID: String
    let previousTransactionIndex: Int
    let transaction: BitcoinTransaction
    let signatures: [BitcoinTransactionSignature]
    
}
