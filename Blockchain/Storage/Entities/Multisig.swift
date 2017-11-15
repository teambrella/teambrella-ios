//
/* Copyright(C) 2017 Teambrella, Inc.
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
import Foundation

class Multisig: NSManagedObject {
    var id: Int { return Int(idValue) }
    // Can be set by EthWallet
    var address: String? {
        get {
            return addressValue
        }
        set {
            addressValue = newValue
        }
    }
    
    var creationTx: String? {
        get {
            return creationTxValue
        }
        set {
            creationTxValue = newValue
        }
    }
    
    var needServerUpdate: Bool {
        get {
            return needServerUpdateValue
        }
        set {
            needServerUpdateValue = newValue
        }
    }
   
    var status: MultisigStatus { return MultisigStatus(rawValue: Int(statusValue)) ?? .failed }
    var dateCreated: Date? { return dateCreatedValue }
    var teamID: Int { return teammate?.team.id ?? 0 }
    
    var teammate: Teammate? { return teammateValue }
    
    var cosigners: [Cosigner] {
        let cosignersSet = cosignersValue as? Set<Cosigner> ?? []
        let cosigners = Array(cosignersSet).sorted { $0.keyOrder < $1.keyOrder }
        return cosigners
    }
    
}
