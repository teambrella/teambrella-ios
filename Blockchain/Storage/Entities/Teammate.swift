//
//  BlockchainTeammate.swift
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

class Teammate: NSManagedObject {
    var id: Int { return Int(idValue) }
    var fbName: String? { return fbNameValue }
    var name: String { return nameValue! }
    var publicKey: String? { return publicKeyValue }
    var address: String? { return cryptoAddressValue }
    
    var team: Team {
        return teamValue!
    }
    
    var cosignerOf: Set<Cosigner> {
        return cosignerOfValue as? Set<Cosigner> ?? []
    }
    
//    var cosigners: Set<Cosigner> {
//        return cosignersValue as? Set<Cosigner> ?? []
//    }
    
    var payTos: Set<PayTo> {
        return payTosValue as? Set<PayTo> ?? []
    }
    
    var signatures: [TxSignature] {
        guard let set = signaturesValue as? Set<TxSignature> else { fatalError() }
        
        return Array(set)
    }

    var previousAddress: Multisig? {
        guard let multisigs = multisigsValue as? Set<Multisig> else { return nil }

        for multisig in multisigs where multisig.status == .previous {
            return multisig
        }
        return nil
    }

    var currentAddress: Multisig? {
        guard let multisigs = multisigsValue as? Set<Multisig> else { return nil }

        for multisig in multisigs where multisig.status == .current {
            return multisig
        }
        return nil
    }

    var nextAddress: Multisig? {
        guard let multisigs = multisigsValue as? Set<Multisig> else { return nil }

        for multisig in multisigs where multisig.status == .next {
            return multisig
        }
        return nil
    }
    
//    var addressPrevious: CryptoAddress? {
//        return addresses.filter { $0.status == UserAddressStatus.previous }.first
//    }
//
//    var addressCurrent: CryptoAddress? {
//        return addresses.filter { $0.status == UserAddressStatus.current }.first
//    }
//    
//    var addressNext: CryptoAddress? {
//        return addresses.filter { $0.status == UserAddressStatus.next }.first
//    }
}
