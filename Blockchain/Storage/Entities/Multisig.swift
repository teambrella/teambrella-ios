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
    var address: String? { return addressValue }
    var creationTx: String? { return creationTxValue }
    var teammateID: Int { return Int(teammateIdValue) }
    var status: Int { return Int(statusValue) }
    var dateCreated: Date? { return dateCreatedValue }
    var teammateName: String? { return teammateNameValue }
    var teammatePublicKey: String? { return teammatePublicKey }
    var teamID: Int { return Int(teamIdValue) }
    
    var cosigners: Set<Cosigner> {
        return cosignersValue as? Set<Cosigner> ?? []
    }
}
