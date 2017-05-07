//
//  BlockchainStorageFetcher.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import CoreData

class BlockchainStorageFetcher {
    let storage: TransactionsStorage!
    
    init(storage: TransactionsStorage) {
        self.storage = storage
    }
    
    var firstTeam: BlockchainTeam? {
        let request: NSFetchRequest<BlockchainTeam> = BlockchainTeam.fetchRequest()
        let items = try? storage.context.fetch(request)
        return items?.first
    }
    
    var teammates: [BlockchainTeammate]? {
        let request: NSFetchRequest<BlockchainTeammate> = BlockchainTeammate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
        let items = try? storage.context.fetch(request)
        return items
    }
    
    var resolvableTransactions: [BlockchainTransaction]? {
        let request: NSFetchRequest<BlockchainTransaction> = BlockchainTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.received.rawValue)")
        //request.sortDescriptors = [NSSortDescriptor(key: "resolutionValue", ascending: true)]
        let items = try? storage.context.fetch(request)
        return items
    }
    
    var cosignableTransactions: [BlockchainTransaction]? {
        let request: NSFetchRequest<BlockchainTransaction> = BlockchainTransaction.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.approved.rawValue)" +
            " AND stateValue == \(TransactionState.selectedForCosigning.rawValue)"/* +
            " AND inputs.@count > 0"*/)
        //request.sortDescriptors = [NSSortDescriptor(key: "resolutionValue", ascending: true)]
        let items = try? storage.context.fetch(request)
        return items
    }

//    var pendingPayments: [BlockchainPayTo]? {
//        let request: NSFetchRequest<BlockchainTeammate> = BlockchainPayTo.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
//        let items = try? storage.context.fetch(request)
//        return items
//    }
}
