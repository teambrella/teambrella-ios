//
//  KeychainTransaction+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainTransaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainTransaction> {
        return NSFetchRequest<KeychainTransaction>(entityName: "KeychainTransaction")
    }

    @NSManaged public var amountBTC: NSDecimalNumber?
    @NSManaged public var claimID: Int64
    @NSManaged public var claimTeammateID: Int64
    @NSManaged public var clientResolutionTime: NSDate?
    @NSManaged public var feeBTC: NSDecimalNumber?
    @NSManaged public var id: String?
    @NSManaged public var initiatedTime: NSDate?
    @NSManaged public var isServerUpdateNeeded: Bool
    @NSManaged public var moveToAddressID: String?
    @NSManaged public var processedTime: NSDate?
    @NSManaged public var rawKind: Int16
    @NSManaged public var rawResolution: Int16
    @NSManaged public var rawState: Int16
    @NSManaged public var receivedTime: NSDate?
    @NSManaged public var teammateID: Int64
    @NSManaged public var updateTIme: NSDate?
    @NSManaged public var withdrawReqID: Int64
    @NSManaged public var claimTeammate: KeychainTeammate?
    @NSManaged public var teammate: KeychainTeammate?
    @NSManaged public var input: KeychainInput?
    @NSManaged public var output: KeychainOutput?

}
