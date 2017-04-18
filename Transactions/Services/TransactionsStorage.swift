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
        save { context in
            print("Trying to save json to SQLite\n\n")
            let factory = EntityFactory(context: context)
            let addresses = factory.addresses(json: json["BTCAddresses"])
            let cosigners = factory.cosigners(json: json["Cosigners"])
            let payTos = factory.payTos(json: json["PayTos"])
            let teammates = factory.teammates(json: json["Teammates"])
            let teams = factory.teams(json: json["Teams"])
            let inputs = factory.inputs(json: json["TxInputs"])
            let outputs = factory.outputs(json: json["TxOutputs"])
            let signatures = factory.signatures(json: json["TxSignatures"])
            let transactions = factory.transactions(json: json["Txs"])
        }
    }
    
    func save(block: (_ context: NSManagedObjectContext) -> Void) {
        block(context)
        save(context: context)
        print("saved")
    }
    
    func saveInBackground(block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { [weak self] context in
            block(context)
            self?.save(context: context)
        }
    }
    
    private func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
