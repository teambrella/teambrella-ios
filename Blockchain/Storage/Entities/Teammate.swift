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
    
    var addresses: [CryptoAddress] {
        guard let set = addressesValue as? Set<CryptoAddress> else { fatalError() }
        
        return Array(set)
    }
    
    var signatures: [TxSignature] {
        guard let set = signaturesValue as? Set<TxSignature> else { fatalError() }
        
        return Array(set)
    }
    
    var addressPrevious: CryptoAddress? {
        return addresses.filter { $0.status == UserAddressStatus.previous }.first
    }
    
    var addressCurrent: CryptoAddress? {
        return addresses.filter { $0.status == UserAddressStatus.current }.first
    }
    
    var addressNext: CryptoAddress? {
        return addresses.filter { $0.status == UserAddressStatus.next }.first
    }
}
