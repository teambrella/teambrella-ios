//
//  KeychainTeammate+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainTeammate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainTeammate> {
        return NSFetchRequest<KeychainTeammate>(entityName: "KeychainTeammate")
    }

    @NSManaged public var fbName: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var publicKey: String?
    @NSManaged public var teamID: Int64
    @NSManaged public var payTo: KeychainPayTo?
    @NSManaged public var team: KeychainTeam?
    @NSManaged public var address: KeychainAddress?
    @NSManaged public var cosigners: NSSet?
    @NSManaged public var signature: KeychainSignature?
    @NSManaged public var transactions: NSSet?

}

// MARK: Generated accessors for cosigners
extension KeychainTeammate {

    @objc(addCosignersObject:)
    @NSManaged public func addToCosigners(_ value: KeychainCosigner)

    @objc(removeCosignersObject:)
    @NSManaged public func removeFromCosigners(_ value: KeychainCosigner)

    @objc(addCosigners:)
    @NSManaged public func addToCosigners(_ values: NSSet)

    @objc(removeCosigners:)
    @NSManaged public func removeFromCosigners(_ values: NSSet)

}

// MARK: Generated accessors for transactions
extension KeychainTeammate {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: KeychainTransaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: KeychainTransaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}
