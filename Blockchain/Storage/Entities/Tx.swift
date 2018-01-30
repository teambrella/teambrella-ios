//
//  BlockchainTransaction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.

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

import CoreData

class Tx: NSManagedObject {
    var kind: TransactionKind? { return TransactionKind(rawValue: Int(kindValue)) }
    var resolution: TransactionClientResolution {
        get {
            return TransactionClientResolution(rawValue: Int(resolutionValue)) ?? .none
        }
        set {
            resolutionValue = Int16(newValue.rawValue)
        }
    }
    var state: TransactionState? { return TransactionState(rawValue: Int(stateValue)) }
    var claimID: Int { return Int(claimIDValue) }
    var withdrawReqID: Int { return Int(withdrawReqIDValue) }
    var amount: Decimal { return amountValue! as Decimal }
    var fee: Decimal? { return feeValue as Decimal? }
    var id: UUID { return  UUID(uuidString: idValue!)! }
    var moveToAddressID: String? { return moveToAddressIDValue }
    var isServerUpdateNeeded: Bool {
        get {
            return isServerUpdateNeededValue
        }
        set {
            isServerUpdateNeededValue = newValue
        }
    }
    /// transaction hash
    var cryptoTx: String? {
        get {
            return cryptoTxValue
        }
        set {
            cryptoTxValue = newValue
        }
    }
    var clientResolutionTime: Date? { return clientResolutionTimeValue as Date? }
    var resolutionTime: Date? { return resolutionTimeValue as Date? }
    var initiatedTime: Date? { return initiatedTimeValue as Date? }
    var processedTime: Date? { return processedTimeValue as Date? }
    var receivedTime: Date? { return receivedTimeValue as Date? }
    var updateTime: Date? { return updateTimeValue as Date? }
    
    var teammate: Teammate? {
       // guard let teammate = teammateValue else { fatalError("Teammate for transaction not set") }
        
        return teammateValue
    }
    
    var claimTeammate: Teammate {
        guard let teammate = claimTeammateValue else {
            fatalError("Claim teammate for transaction \(id.uuidString) not set")
        }
        
        return teammate
    }
    
    /*
    var fromAddress: CryptoAddress? {
        return kind == .saveFromPreviousWallet ? teammate.addressPrevious : teammate.addressCurrent
    }
    */
    
    /// TxInputs sorted by UUID id values
    var inputs: [TxInput] {
        guard let set = inputsValue as? Set<TxInput> else {
            log("couldn't form array from set of TxInput", type: [.error, .crypto])
            return []
        }
        
        return Array(set).sorted { $0.id < $1.id }
    }
    
    var outputs: [TxOutput] {
        guard let set = outputsValue as? Set<TxOutput> else { return [] }
        
        return Array(set).sorted { $0.id < $1.id }
    }

    var fromMultisig: Multisig? {
        if let kind = kind, kind == .saveFromPreviousWallet {
            return teammate?.previousAddress
        } else {
            return teammate?.currentAddress
        }
    }

    var toMultisig: Multisig? {
        if let kind = kind, kind == .saveFromPreviousWallet {
            return teammate?.currentAddress
        } else {
            return teammate?.nextAddress
        }
    }
    
}
