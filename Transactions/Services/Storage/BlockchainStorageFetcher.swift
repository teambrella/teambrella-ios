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
    
    var firstTeam: Team? {
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        let items = try? storage.context.fetch(request)
        return items?.first
    }
    
    var teammates: [Teammate]? {
        let request: NSFetchRequest<Teammate> = Teammate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
        let items = try? storage.context.fetch(request)
        return items
    }
    
    var resolvableTransactions: [Tx]? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.received.rawValue)")
        //request.sortDescriptors = [NSSortDescriptor(key: "resolutionValue", ascending: true)]
        let items = try? storage.context.fetch(request)
        return items
    }
    
    var cosignableTransactions: [Tx]? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
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
