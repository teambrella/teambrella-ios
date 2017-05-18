//
//  BtcAddress.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class BtcAddress: NSManagedObject {
    var status: UserAddressStatus {
        get {
            return UserAddressStatus(rawValue: Int(statusValue)) ?? .invalid
        }
        set {
            statusValue = Int16(newValue.rawValue)
        }
    }
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
