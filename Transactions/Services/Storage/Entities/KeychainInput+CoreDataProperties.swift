//
//  KeychainInput+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainInput {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainInput> {
        return NSFetchRequest<KeychainInput>(entityName: "KeychainInput")
    }

    @NSManaged public var ammount: NSDecimalNumber?
    @NSManaged public var id: String?
    @NSManaged public var previousTransactionID: String?
    @NSManaged public var previousTransactionIndex: Int64
    @NSManaged public var transacrionID: String?
    @NSManaged public var transaction: KeychainTransaction?
    @NSManaged public var signature: KeychainSignature?

}
