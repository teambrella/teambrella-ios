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
        let items = try? storage.context.fetch(request)
        return items
    }
}
