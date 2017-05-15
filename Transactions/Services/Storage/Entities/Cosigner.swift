//
//  Cosigner.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class Cosigner: NSManagedObject {
    var keyOrder: Int { return Int(keyOrderValue) }
    var addressID: String { return addressIDValue! }
    
    override var description: String {
        return "Cosigner for address: \(address?.address ?? "none"), order: \(keyOrder)"
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
