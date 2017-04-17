//
//  BitcoinTransactionInput.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct BitcoinTransactionInput {
    let id: UUID
    let transactionID: UUID
    let ammount: Decimal
    let previousTransactionID: String
    let previousTransactionIndex: Int
    var transaction: BitcoinTransaction?
    var signatures: [BitcoinTransactionSignature]
    
}

public struct BitcoinTransactionInputFactory {    
    func items(from json: JSON) -> [BitcoinTransactionInput] {
        return json.arrayValue.map { self.item(json: $0) }
    }
    
    func item(json: JSON) -> BitcoinTransactionInput {
        let id = UUID()
        let transactionID = UUID()
        let ammount: Decimal = 0
        let previousTransactionID = ""
        let previousTransactionIndex = 0
        let transaction: BitcoinTransaction? = nil
        let signatures: [BitcoinTransactionSignature] = []
        return BitcoinTransactionInput(id: id,
                                       transactionID: transactionID,
                                       ammount: ammount,
                                       previousTransactionID: previousTransactionID,
                                       previousTransactionIndex: previousTransactionIndex,
                                       transaction: transaction,
                                       signatures: signatures)
    }
}
