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
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsModel")
        container.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(String(describing: error))
            }
            
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.container = container
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents path: \(documentsPath)")
    }
    
    func update(with json: JSON) {
        let start = DispatchTime.now()
        saveInBackground(block: { context in
            print("Trying to save json to context\n\n")
            let factory = EntityFactory(context: context)
            let teams = factory.teams(json: json["Teams"])
            let teammates = factory.teammates(json: json["Teammates"], teams: teams)
            let addresses = factory.addresses(json: json["BTCAddresses"], teammates: teammates)
            _ = factory.cosigners(json: json["Cosigners"],
                                              addresses: addresses,
                                              teammates: teammates)
            _ = factory.payTos(json: json["PayTos"], teammates: teammates)
            _ = factory.inputs(json: json["TxInputs"])
            _ = factory.outputs(json: json["TxOutputs"])
            _ = factory.signatures(json: json["TxSignatures"])
            _ = factory.transactions(json: json["Txs"], teammates: teammates)
            let fetch = DispatchTime.now()
            print("Parsing time: \(Double(fetch.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000000) sec")
        }) {
            let end = DispatchTime.now()
            print("Total execution time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000000) sec")
        }
    }
    
    func save(block: (_ context: NSManagedObjectContext) -> Void) {
        block(context)
        save(context: context)
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
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
            return true
        }
        return false
    }
    
}
