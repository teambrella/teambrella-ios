//
//  TransactionsStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import SwiftyJSON

class TransactionsStorage {
    struct Constant {
        static let lastUpdatedKey = "TransactionsServer.lastUpdatedKey"
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsModel")
        container.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(String(describing: error))
            }
            
            //self.container = container
        }
        return container
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
        saveInBackground(block: { context in
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            print("Trying to save json to context\n\n")
            let factory = EntityFactory(context: context)
            let teams = factory.teams(json: json["Teams"])
            let teammates = factory.teammates(json: json["Teammates"], teams: teams)
            let addresses = factory.addresses(json: json["BTCAddresses"], teammates: teammates)
            _ = factory.transactions(json: json["Txs"], teammates: teammates)
            _ = factory.cosigners(json: json["Cosigners"],
                                  teammates: teammates)
            _ = factory.payTos(json: json["PayTos"], teammates: teammates)
            _ = factory.inputs(json: json["TxInputs"])
            _ = factory.outputs(json: json["TxOutputs"])
            _ = factory.signatures(json: json["TxSignatures"])
            let fetch = DispatchTime.now()
            print("Parsing time: \(Double(fetch.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000) sec")
        }) { [weak self] in
            let end = DispatchTime.now()
            print("Total execution time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000) sec")
            self?.lastUpdated = updateTime
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func save(block: (_ context: NSManagedObjectContext) -> Void) {
        block(context)
        save(context: context)
    }
    
    func dispose() {
        context.rollback()
    }
    
    func saveInBackground(block: @escaping (_ context: NSManagedObjectContext) -> Void,
                          completion: (() -> Void)? = nil) {
        container.performBackgroundTask { [weak self] context in
            guard let me = self else { return }
            
            block(context)
            let isSaved = me.save(context: context)
            print(isSaved ? "saved context" : "failed to save context")
            completion?()
        }
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
