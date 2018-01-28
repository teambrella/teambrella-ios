//
//  Cosigner.swift
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

class Cosigner: NSManagedObject {
    var keyOrder: Int { return Int(keyOrderValue) }
    var multisigID: Int64 { return multisigIDValue }
    
    var teammate: Teammate {
        return teammateValue!
    }
    
    var multisig: Multisig {
        return multisigValue!
    }

//    var bSignature: Data {
//       
//    }
    
    override var description: String {
        return "Cosigner for multisig: \(multisig.id), order: \(keyOrder)"
    }
}

extension Cosigner {
    static func cosigners(for teammate: Teammate) -> [Cosigner] {
        guard let context = teammate.managedObjectContext else { return [] }
        
        let request: NSFetchRequest<Cosigner> = Cosigner.fetchRequest()
        request.predicate = NSPredicate(format: "teammate = %@", teammate)
        let result = try? context.fetch(request)
        return result ?? []
    }
}
