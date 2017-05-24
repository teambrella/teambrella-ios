//
//  TeambrellaService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol TeambrellaServiceDelegate: class {
    func teambrellaDidUpdate(service: TeambrellaService)
}

class TeambrellaService {
    let storage = BlockchainStorage()
    lazy var blockchain: BlockchainService = {  BlockchainService(storage: self.storage) }()
    weak var delegate: TeambrellaServiceDelegate?
    var fetcher: BlockchainStorageFetcher { return storage.fetcher }
    var key: Key { return storage.key }

    
    init() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update() {
        storage.updateData { success in
            if success {
                self.blockchain.updateData()
                self.save()
            }
        }
        
    }
    
    func save() {
        storage.serverUpdateToLocalDb { success in
             self.delegate?.teambrellaDidUpdate(service: self)
        }
    }
    
}

// Helpers

extension TeambrellaService {
    func approve(tx: Tx) {
        fetcher.transactionsChangeResolution(txs: [tx], to: .approved)
        self.delegate?.teambrellaDidUpdate(service: self)
        //update()
    }
}
