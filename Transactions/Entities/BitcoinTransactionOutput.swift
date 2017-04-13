//
//  BitcoinTransactionOutput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinTransactionOutput {
    let id: UUID
    let transactionID: UUID
    let payToID: UUID?
    let ammount: Decimal
    let transaction: BitcoinTransaction
    let payTo: BitcoinPayTo
    
}
