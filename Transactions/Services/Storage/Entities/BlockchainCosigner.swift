//
//  BlockchainCosigner.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class BlockchainCosigner: NSManagedObject {
    var keyOrder: Int { return Int(keyOrderValue) }
    override var description: String {
        return "Cosigner for address: \(address?.address ?? "none"), order: \(keyOrder)"
    }
}

extension BlockchainCosigner {
    static func cosigners(for teammate: BlockchainTeammate) -> [BlockchainCosigner] {
        guard let context = teammate.managedObjectContext else { return [] }
        
        let request: NSFetchRequest<BlockchainCosigner> = BlockchainCosigner.fetchRequest()
        request.predicate = NSPredicate(format: "teammate = %@", teammate)
        let result = try? context.fetch(request)
        return result ?? []
    }
}
