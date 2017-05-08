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
    
    var addressPrevious: BtcAddress? {
        return (addresses as? Set<BtcAddress>)?.filter { $0.status == UserAddressStatus.previous }.first
    }
    
    var addressFirst: BtcAddress? {
        return (addresses as? Set<BtcAddress>)?.filter { $0.status == UserAddressStatus.current }.first
    }
    
    var addressNext: BtcAddress? {
        return (addresses as? Set<BtcAddress>)?.filter { $0.status == UserAddressStatus.next }.first
    }
}
