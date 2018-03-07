//
//  CoreDataStorage.swift
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

class CoreDataStorage {
    struct Constant {
        static let lastUpdatedKey = "TransactionsServer.lastUpdatedKey"
    }
    
    lazy var container: NSPersistentContainer = { self.createPersistentContainer() }()
    var context: NSManagedObjectContext { return container.viewContext }
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        log("Teambrella documents path: \(documentsPath)", type: .database)
    }
    
    func clear() throws {
        NotificationCenter.default.post(name: .teambrellaCoreDataWillClear, object: nil)
        context.reset()
        context.shouldDeleteInaccessibleFaults = true
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask);
        var dbUrl = urls[urls.count - 1];
        dbUrl = dbUrl.appendingPathComponent("Application Support/TransactionsModel.sqlite")
            try container.persistentStoreCoordinator.destroyPersistentStore(at: dbUrl,
                                                                                      ofType: NSSQLiteStoreType,
                                                                                      options: nil);
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                                  configurationName: nil,
                                                                                  at: dbUrl,
                                                                                  options: nil);
    }
    
    func createPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "TransactionsModel")
        container.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(String(describing: error))
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return container
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
                log("Unresolved error \(nserror), \(nserror.userInfo)", type: [.error, .database])
                return false
            }
            return true
        }
        return false
    }
    
}
