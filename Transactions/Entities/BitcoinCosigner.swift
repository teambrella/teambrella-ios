//
//  BitcoinCosigner.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public struct BitcoinCosigner {
    let teammateID: Int
    let addressID: String
    let keyOrder: Int
    
    let address: BitcoinAddress
    let teammate: BitcoinTeammate
//    let disbandingTransactionSignatures: [DisbandingTransactionSignature]
    
}
