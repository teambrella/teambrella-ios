//
//  TxOutput.swift
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

class TxOutput: NSManagedObject {
    /// amount in Bitcoins
    var amount: Decimal { return amountValue! as Decimal }
    var id: String { return idValue! }
//    var payToID: String { return payToIDValue! }
//    var transactionID: String { return transactionIDValue! }
    
    var transaction: Tx {
        return transactionValue!
    }
    
    var payTo: PayTo {
        return payToValue!
    }
}
