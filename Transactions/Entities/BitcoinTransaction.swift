//
//  Transaction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

/// <summary>
/// Dual responsibility entity:
/// 1) Incoming DTO (Data Transfer Object) from teambrella server.
/// 2) Local DB entity for that server DTO.
/// </summary>
public struct BitcoinTransaction {
    public let id: UUID
    public let teammateID: Int
    public let amountBTC: Decimal?
    public let claimID: Int?
    public let claimTeammateID: Int?
    public let withdrawReqID: Int?
    public let kind: TransactionKind
    public let state: TransactionState
    public let initiatedTime: Date
    
    public let feeBTC: Decimal?
    public let moveToAddressID: String
    public let updateTime: Date
    public let receivedTime: Date
    public let processedTime: Date
    
    public let clientResolutionTime: Date?
    public let resolution: TransactionClientResolution
    public let isUpdateServerNeeded: Bool
    
    public let teammate: BitcoinTeammate
    public let claimTeammate: BitcoinTeammate
    public let moveToAddress: BitcoinAddress
    public let inputs: [BitcoinTransactionInput]
    public let outputs: [BitcoinTransactionOutput]
    
}
