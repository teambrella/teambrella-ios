//
//  BlockchainTeam.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class Team: NSManagedObject {
    var id: Int { return Int(idValue) }
    var name: String { return nameValue! }
    var isTestnet: Bool { return isTestnetValue }
    
    var autoApprovalCosignGoodAddress: Int { return Int(autoApprovalCosignGoodAddressValue) }
    var autoApprovalCosignNewAddress: Int { return Int(autoApprovalCosignNewAddressValue) }
    var autoApprovalMyGoodAddress: Int { return Int(autoApprovalMyGoodAddressValue) }
    var autoApprovalMyNewAddress: Int { return Int(autoApprovalMyNewAddressValue) }
    var autoApprovalOff: Int { return Int(autoApprovalOffValue) }
    var okAge: Int { return Int(okAgeValue) }
    
    var teammates: Set<Teammate> {
        return teammatesValue as? Set<Teammate> ?? []
    }
}

extension Team {
    func me(user: User) -> Teammate? {
        let pubKey = user.key().publicKey
        
        return teammates.filter { $0.publicKey == pubKey }.first
    }
    
    var network: BTCNetwork {
        return isTestnet ? BTCNetwork.testnet() : BTCNetwork.mainnet()
    }
    
    var displayName: String {
        return isTestnet ? "[testnet]" : "" + name
    }
}
