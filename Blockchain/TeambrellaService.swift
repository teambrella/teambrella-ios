//
//  TeambrellaService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.

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

import Foundation
import SwiftyJSON

protocol TeambrellaServiceDelegate: class {
    func teambrellaDidUpdate(service: TeambrellaService)
}

class TeambrellaService {
    let storage = BlockchainStorage()
    lazy var blockchain: BlockchainService = {  BlockchainService(storage: self.storage) }()
    weak var delegate: TeambrellaServiceDelegate?
    var key: Key { return storage.key }

    
    init() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startUpdating() {
        update()
    }
    
    func update() {
        log("Teambrella service begins updates", type: .crypto)
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
    
    func clear() {
        storage.clear()
    }
    
}

// Helpers

extension TeambrellaService {
    func approve(tx: Tx) {
        storage.contentProvider.transactionsChangeResolution(txs: [tx], to: .approved)
        self.delegate?.teambrellaDidUpdate(service: self)
        //update()
    }
}
