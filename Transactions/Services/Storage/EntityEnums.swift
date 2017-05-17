//
//  EntityEnums.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public enum UserAddressStatus: Int {
    case previous = 0
    case current = 1
    case next = 2
    case archive = 3
    
    // extra values, that are valid for local DB only
    case invalid = 4
    case serverPrevious = 10
    case serverCurrent = 11
    case serverNext = 12
}

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
    
    var string: String {
        return "\(self)".components(separatedBy: ".").last ?? ""
    }
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
