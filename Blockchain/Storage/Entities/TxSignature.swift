//
//  BlockchainSignature.swift
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

class TxSignature: NSManagedObject {
    var teammateID: Int { return Int(teammateIDValue) }
    var id: UUID {
        get {
        return UUID(uuidString: idValue!)!
        }
        set {
            idValue = newValue.uuidString
        }
    }
    var inputID: UUID { return UUID(uuidString:inputIDValue!)! }
    var isServerUpdateNeeded: Bool {
        get {
            return isServerUpdateNeededValue
        }
        set {
            isServerUpdateNeededValue = newValue
        }
    }
    var signature: Data { return signatureValue! as Data }
    var teammate: Teammate? { return teammateValue }
    var input: TxInput? { return inputValue }
    
    class func create(in context: NSManagedObjectContext) -> TxSignature {
        let signature = TxSignature(context: context)
        signature.id = UUID()
        return signature
    }
}
