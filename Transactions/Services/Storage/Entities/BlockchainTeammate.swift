//
//  BlockchainTeammate.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class BlockchainTeammate: NSManagedObject {
    var id: Int { return Int(idValue) }
    var fbName: String? { return fbNameValue }
    var name: String { return nameValue! }
    var publicKey: String? { return publicKeyValue }
    
    var addressPrevious: BlockchainAddress? {
        return (addresses as? Set<BlockchainAddress>)?.filter { $0.status == UserAddressStatus.previous }.first
    }
    
    var addressFirst: BlockchainAddress? {
        return (addresses as? Set<BlockchainAddress>)?.filter { $0.status == UserAddressStatus.current }.first
    }
    
    var addressNext: BlockchainAddress? {
        return (addresses as? Set<BlockchainAddress>)?.filter { $0.status == UserAddressStatus.next }.first
    }
}
