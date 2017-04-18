//
//  KeychainAddress+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainAddress> {
        return NSFetchRequest<KeychainAddress>(entityName: "KeychainAddress")
    }

    @NSManaged public var address: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var rawStatus: Int16
    @NSManaged public var teammateID: Int64
    @NSManaged public var cosigners: NSSet?
    @NSManaged public var moveFundsTransactions: KeychainTransaction?
    @NSManaged public var teammate: KeychainTeammate?

}

// MARK: Generated accessors for cosigners
extension KeychainAddress {

    @objc(addCosignersObject:)
    @NSManaged public func addToCosigners(_ value: KeychainCosigner)

    @objc(removeCosignersObject:)
    @NSManaged public func removeFromCosigners(_ value: KeychainCosigner)

    @objc(addCosigners:)
    @NSManaged public func addToCosigners(_ values: NSSet)

    @objc(removeCosigners:)
    @NSManaged public func removeFromCosigners(_ values: NSSet)

}
