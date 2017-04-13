//
//  Transaction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public enum TransactionKind: Int {
    /// voting compensation or reimbursement
    case payout = 0
    case withdraw = 1
    case moveToNextWallet = 2
    case saveFromPreviousWallet = 3
}

public enum TransactionState: Int {
    case created = 0
    case approvedMaster = 1
    case approvedCosigners = 2
    // =?>  SelectedForCosigning (select by date)
    case approvedAll = 3
    case blockedMaster = 4
    case blockedCosigners = 5
    // => BeingCosigned (after at least half co-signers got signature tasks)
    case selectedForCosigning = 6
    case beingCosigned = 7
    case cosigned = 8
    case published = 9
    case confirmed = 10
    case errorCosignersTimeout = 100
    case errorSubmitToBlockchain = 101
    // bad id, kind or amounts
    case errorBadRequest = 102
    case errorOutOfFunds = 103
    case errorTooManyUtxos = 104
}

public enum TransactionClientResolution: Int {
    case none = 0
    case received = 1
    case approved = 2
    case blocked = 3
    case signed = 4
    case published = 5
    case errorCosignersTimeout = 100
    case errorSubmitToBlockchain = 101
    // bad id, kind or amounts
    case errorBadRequest = 102
    case errorOutOfFunds = 103
}

/// <summary>
/// Dual responsibility entity:
/// 1) Incoming DTO (Data Transfer Object) from teambrella server.
/// 2) Local DB entity for that server DTO.
/// </summary>
public struct BitcoinTransaction
{
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
