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
import Foundation

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
    
    func backupPersistentStore() throws -> TemporaryFile {
        return try container.persistentStoreCoordinator.backupPersistentStore(atIndex: 0)
    }
}

/// props to Ole Begemann
///   https://oleb.net/blog/2018/03/core-data-sqlite-backup/
///
/// Safely copies the specified `NSPersistentStore` to a temporary file.
/// Useful for backups.
///
/// - Parameter index: The index of the persistent store in the coordinator's
///   `persistentStores` array. Passing an index that doesn't exist will trap.
///
/// - Returns: The URL of the backup file, wrapped in a TemporaryFile instance
///   for easy deletion.
extension NSPersistentStoreCoordinator {
    func backupPersistentStore(atIndex index: Int) throws -> TemporaryFile {
        // Inspiration: https://stackoverflow.com/a/22672386
        // Documentation for NSPersistentStoreCoordinate.migratePersistentStore:
        // "After invocation of this method, the specified [source] store is
        // removed from the coordinator and thus no longer a useful reference."
        // => Strategy:
        // 1. Create a new "intermediate" NSPersistentStoreCoordinator and add
        //    the original store file.
        // 2. Use this new PSC to migrate to a new file URL.
        // 3. Drop all reference to the intermediate PSC.
        precondition(persistentStores.indices.contains(index), "Index \(index) doesn't exist in persistentStores array")
        let sourceStore = persistentStores[index]
        let backupCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let intermediateStoreOptions = (sourceStore.options ?? [:])
            .merging([NSReadOnlyPersistentStoreOption: true],
                     uniquingKeysWith: { $1 })
        let intermediateStore = try backupCoordinator.addPersistentStore(
            ofType: sourceStore.type,
            configurationName: sourceStore.configurationName,
            at: sourceStore.url,
            options: intermediateStoreOptions
        )
        
        let backupStoreOptions: [AnyHashable: Any] = [
            NSReadOnlyPersistentStoreOption: true,
            // Disable write-ahead logging. Benefit: the entire store will be
            // contained in a single file. No need to handle -wal/-shm files.
            // https://developer.apple.com/library/content/qa/qa1809/_index.html
            NSSQLitePragmasOption: ["journal_mode": "DELETE"],
            // Minimize file size
            NSSQLiteManualVacuumOption: true,
        ]
        
        // Filename format: basename-date.sqlite
        // E.g. "MyStore-20180221T200731.sqlite" (time is in UTC)
        func makeFilename() -> String {
            let basename = sourceStore.url?.deletingPathExtension().lastPathComponent ?? "store-backup"
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime]
            let dateString = dateFormatter.string(from: Date())
            return "\(basename)-\(dateString).sqlite"
        }
        
        let backupFilename = makeFilename()
        let backupFile = try TemporaryFile(creatingTempDirectoryForFilename: backupFilename)
        try backupCoordinator.migratePersistentStore(intermediateStore, to: backupFile.fileURL, options: backupStoreOptions, withType: NSSQLiteStoreType)
        return backupFile
    }
}


/// A wrapper around a temporary file in a temporary directory. The directory
/// has been especially created for the file, so it's safe to delete when you're
/// done working with the file.
///
/// Call `deleteDirectory` when you no longer need the file.
struct TemporaryFile {
    let directoryURL: URL
    let fileURL: URL
    /// Deletes the temporary directory and all files in it.
    let deleteDirectory: () throws -> Void
    
    /// Creates a temporary directory with a unique name and initializes the
    /// receiver with a `fileURL` representing a file named `filename` in that
    /// directory.
    ///
    /// - Note: This doesn't create the file!
    init(creatingTempDirectoryForFilename filename: String) throws {
        let (directory, deleteDirectory) = try FileManager.default.urlForUniqueTemporaryDirectory()
        self.directoryURL = directory
        self.fileURL = directory.appendingPathComponent(filename)
        self.deleteDirectory = deleteDirectory
    }
}

extension FileManager {
    /// Creates a temporary directory with a unique name and returns its URL.
    ///
    /// - Returns: A tuple of the directory's URL and a delete function.
    ///   Call the function to delete the directory after you're done with it.
    ///
    /// - Note: You should not rely on the existence of the temporary directory
    ///   after the app is exited.
    func urlForUniqueTemporaryDirectory(preferredName: String? = nil) throws -> (url: URL, deleteDirectory: () throws -> Void) {
        let basename = preferredName ?? UUID().uuidString
        
        var counter = 0
        var createdSubdirectory: URL? = nil
        repeat {
            do {
                let subdirName = counter == 0 ? basename : "\(basename)-\(counter)"
                let subdirectory = temporaryDirectory.appendingPathComponent(subdirName, isDirectory: true)
                try createDirectory(at: subdirectory, withIntermediateDirectories: false)
                createdSubdirectory = subdirectory
            } catch CocoaError.fileWriteFileExists {
                // Catch file exists error and try again with another name.
                // Other errors propagate to the caller.
                counter += 1
            }
        } while createdSubdirectory == nil
        
        let directory = createdSubdirectory!
        let deleteDirectory: () throws -> Void = {
            try self.removeItem(at: directory)
        }
        return (directory, deleteDirectory)
    }
}
