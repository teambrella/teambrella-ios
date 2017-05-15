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
    
    var addresses: [BtcAddress] {
        guard let set = addressesValue as? Set<BtcAddress> else { fatalError() }
        
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
