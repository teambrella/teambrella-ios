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

class Unconfirmed: NSManagedObject {
    var multisigId: Int {
        get {
            return Int(multisigIdValue)
        }
        set {
            multisigIdValue = Int64(newValue)
        }
    }
    var txID: String? { return txIdValue }
    var cryptoTx: String? { return cryptoTxValue }
    var cryptoFee: Int { return Int(cryptoFeeValue) }
    var cryptoNonce: Int { return Int(cryptoNonceValue) }
    var dateCreated: Date? { return dateCreatedValue }
    
}
