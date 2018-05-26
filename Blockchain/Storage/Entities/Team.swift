//
//  BlockchainTeam.swift
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
        let pubKey = user.key(in: KeyStorage.shared).publicKey
        
        return teammates.filter { $0.publicKey == pubKey }.first
    }
    
    var network: BTCNetwork {
        return isTestnet ? BTCNetwork.testnet() : BTCNetwork.mainnet()
    }
    
    var displayName: String {
        return isTestnet ? "[testnet]" : "" + name
    }
}
