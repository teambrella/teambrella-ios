//
//  BlockchainTeammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
    
    var addresses: [BtcAddress] {
        guard let set = addressesValue as? Set<BtcAddress> else { fatalError() }
        
        return Array(set)
    }
    
    var signatures: [TxSignature] {
        guard let set = signaturesValue as? Set<TxSignature> else { fatalError() }
        
        return Array(set)
    }
    
    var addressPrevious: BtcAddress? {
        return addresses.filter { $0.status == UserAddressStatus.previous }.first
    }
    
    var addressCurrent: BtcAddress? {
        return addresses.filter { $0.status == UserAddressStatus.current }.first
    }
    
    var addressNext: BtcAddress? {
        return addresses.filter { $0.status == UserAddressStatus.next }.first
    }
}
