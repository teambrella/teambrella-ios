//
//  TransactionsStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import SwiftyJSON

class BlockchainStorage {
    struct Constant {
        static let lastUpdatedKey = "TransactionsServer.lastUpdatedKey"
    }
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
    private(set) var lastUpdated: Int64 {
        get {
            return UserDefaults.standard.value(forKey: Constant.lastUpdatedKey) as? Int64 ?? 0
        }
        set {
            let prev = lastUpdated
            print("last updated changed from \(prev)")
            UserDefaults.standard.set(newValue, forKey: Constant.lastUpdatedKey)
            UserDefaults.standard.synchronize()
            print("last updated changed to \(newValue)")
            print("updates delta = \(Double(newValue - prev) / 10_000_000) seconds")
        }
    }
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents path: \(documentsPath)")
    }
    
    func update(with json: JSON, updateTime: Int64, completion: @escaping () -> Void) {
        let start = DispatchTime.now()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        print("Trying to save json to context\n\n")
        let factory = EntityFactory(fetcher: self.fetcher)
        factory.createOrUpdateEntities(json: json)
        let fetch = DispatchTime.now()
        print("Parsing time: \(Double(fetch.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000) sec")
        updateAddresses()
        save(context: context)
        let end = DispatchTime.now()
        print("Total execution time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000) sec")
        lastUpdated = updateTime
        completion()
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
    
//    func saveInBackground(block: @escaping (_ context: NSManagedObjectContext) -> Void,
//                          completion: (() -> Void)? = nil) {
//        container.performBackgroundTask { [weak self] context in
//            guard let me = self else { return }
//            
//            block(context)
//            let isSaved = me.save(context: context)
//            print(isSaved ? "saved context" : "failed to save context")
//            completion?()
//        }
//    }
    
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
