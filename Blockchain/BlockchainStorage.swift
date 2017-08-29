//
//  TransactionsStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.

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
import SwiftyJSON

class BlockchainStorage {
    struct Constant {
        static let lastUpdatedKey = "TransactionsServer.lastUpdatedKey"
    }
    let server = BlockchainServer()
    var key: Key { return Key(base58String: self.fetcher.user.privateKey, timestamp: self.server.timestamp) }
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsModel")
        container.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(String(describing: error))
            }
        }
        return container
    }()
    lazy var fetcher: BlockchainStorageFetcher = {
        return BlockchainStorageFetcher(storage: self)
    }()
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents path: \(documentsPath)")
    }
    
    func updateData(completion: @escaping (Bool) -> Void) {
        server.initClient(privateKey: fetcher.user.privateKey) { [unowned self] success in
            if success {
                self.autoApproveTransactions()
                self.serverUpdateToLocalDb { success in
                    if success {
                        self.updateAddresses()
                        completion(true)
                    } else {
                       completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func serverUpdateToLocalDb(completion: @escaping (Bool) -> Void) {
        let txsToUpdate = fetcher.transactionsNeedServerUpdate
        let signatures = fetcher.signaturesToUpdate
        let user = fetcher.user
        server.getUpdates(privateKey: user.privateKey,
                          lastUpdated: user.lastUpdated,
                          transactions: txsToUpdate,
                          signatures: signatures) { [unowned self] reply in
                            switch reply {
                            case .success(let json, let timestamp):
                                self.context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                                let factory = EntityFactory(fetcher: self.fetcher)
                                factory.updateLocalDb(txs: txsToUpdate, signatures: signatures, json: json)
                                user.lastUpdated = timestamp
                                completion(true)
                                break
                            case .failure(let error):
                                print("server request failed with error: \(error)")
                                completion(false)
                            }
        }
    }
    
    func autoApproveTransactions() {
        let txs = fetcher.transactionsResolvable
        for tx in txs {
            let daysLeft = fetcher.daysToApproval(tx: tx, isMyTx: fetcher.isMy(tx: tx))
            if daysLeft <= 0 {
                tx.resolution = .approved
                tx.isServerUpdateNeeded = true
            }
        }
        save()
    }
    
    private func updateAddresses() {
        for teammate in fetcher.teammates {
            guard teammate.addresses.isEmpty == false else { continue }
            
            if teammate.addressCurrent == nil {
                let filtered = teammate.addresses.filter { $0.status == UserAddressStatus.current }
                if let curServerAddress = filtered.first {
                    curServerAddress.status = .current
                }
            }
        }
    }
    
    func save(block:((_ context: NSManagedObjectContext) -> Void)? = nil) {
        block?(context)
        save(context: context)
    }
    
    func dispose() {
        context.rollback()
    }
    
    @discardableResult
    private func save(context: NSManagedObjectContext) -> Bool {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
            return true
        }
        return false
    }
    
}
