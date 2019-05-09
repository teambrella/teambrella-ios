//
//  EntityEnums.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

public enum UserAddressStatus: Int, EnumStringConvertible {
    case previous       = 0
    case current        = 1
    case next           = 2
    case archive        = 3

    // extra values, that are valid for local DB only
    case invalid        = 4
    case serverPrevious = 10
    case serverCurrent  = 11
    case serverNext     = 12
}

public enum TransactionKind: Int, EnumStringConvertible, Decodable {
    /// voting compensation or reimbursement
    case payout                 = 0 //reimbursement payouts only
    case withdraw               = 1
    case moveToNextWallet       = 2
    case saveFromPreviousWallet = 3
    case topup                  = 4
    case votingPayout           = 100

    var localizationKey: String { return "General.TransactionKind.\(self)" }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = TransactionKind(rawValue: value) ?? .payout
    }
}

public enum TransactionState: Int, EnumStringConvertible, Decodable {
    case queued                      = -100

    case created                     = 0
    case approvedMaster              = 1
    case approvedCosigners           = 2
    // =?>  SelectedForCosigning (select by date)
    case approvedAll                 = 3
    case blockedMaster               = 4
    case blockedCosigners            = 5
    // => BeingCosigned (after at least half co-signers got signature tasks)
    case selectedForCosigning        = 6
    case beingCosigned               = 7
    case cosigned                    = 8
    case published                   = 9
    case confirmed                   = 10
    case errorCosignersTimeout       = 100
    case errorSubmitToBlockchain     = 101
    // bad id, kind or amounts
    case errorBadRequest             = 102
    case errorOutOfFunds             = 103
    case errorTooManyUtxos           = 104

    case errorBlockchainVerification = 105
    case errorTechProblem            = 106

    var isProcessing: Bool { return self.rawValue >= 0 && self.rawValue < 10 }
    var isQueued: Bool { return self == .queued }
    var isHistory: Bool { return self.rawValue >= 10 }
    var isError: Bool { return self.rawValue >= 100 }
    
    init(decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = TransactionState(rawValue: value) ?? .queued
    }
    
    var localizationKey: String { return "General.TransactionState.\(self)" }
}

public enum TransactionClientResolution: Int, EnumStringConvertible {
    case none                    = 0
    case received                = 1
    case approved                = 2
    case blocked                 = 3
    case signed                  = 4
    case published               = 5
    case errorCosignersTimeout   = 100
    case errorSubmitToBlockchain = 101
    // bad id, kind or amounts
    case errorBadRequest         = 102
    case errorOutOfFunds         = 103
}

/// user multisig (address) status 
public enum MultisigStatus: Int {
    case previous = 0
    case current  = 1
    case next     = 2
    case archive  = 3
    case failed   = -400
}


protocol EnumStringConvertible {
    var string: String { get }
}

extension EnumStringConvertible {
    var string: String { return "\(self)".components(separatedBy: ".").last ?? "" }
}
