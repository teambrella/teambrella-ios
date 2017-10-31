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

class CryptoAddress: NSManagedObject {
    var status: UserAddressStatus {
        get {
            return UserAddressStatus(rawValue: Int(statusValue)) ?? .invalid
        }
        set {
            statusValue = Int16(newValue.rawValue)
        }
    }
    var teammate: Teammate { return teammateValue! }
    var address: String { return addressValue! }
    var dateCreated: Date { return dateCreatedValue! as Date }
    
    var cosigners: [Cosigner] {
        guard let context = managedObjectContext else { return [] }
        
        let request: NSFetchRequest<Cosigner> = Cosigner.fetchRequest()
        request.predicate = NSPredicate(format: "addressIDValue == %@", address)
        let result = try? context.fetch(request)
        return result ?? []
        
        //        guard let set = cosignersValue as? Set<Cosigner> else { return [] }
        //
        //        return Array(set).sorted { $0.keyOrder < $1.keyOrder }
    }
    
}
