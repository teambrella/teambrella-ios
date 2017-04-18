//
//  KeychainOutput+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainOutput {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainOutput> {
        return NSFetchRequest<KeychainOutput>(entityName: "KeychainOutput")
    }

    @NSManaged public var ammount: Int64
    @NSManaged public var id: String?
    @NSManaged public var payToID: String?
    @NSManaged public var transactionID: String?
    @NSManaged public var payTo: KeychainPayTo?
    @NSManaged public var transaction: KeychainTransaction?

}
