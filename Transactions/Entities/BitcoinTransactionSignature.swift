//
//  BitcoinTransactionSignature.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinTransactionSignature {
    let id = UUID()
    let transactionInputID: UUID
    let teammateID: Int
    let signature: Data
    let transactionInput: BitcoinTransactionInput
    let teammate: BitcoinTeammate
    let isServerNeedsUpdate: Bool
    
}
