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
            guard error == nil else { fatalError(String(describing: error))
                
            }
            self.container = container
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func update(with json: JSON) {
        saveInBackground { context in
            
        }
    }
    
    func save(block: (_ context: NSManagedObjectContext) -> Void) {
        block(context)
        save(context: context)
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
