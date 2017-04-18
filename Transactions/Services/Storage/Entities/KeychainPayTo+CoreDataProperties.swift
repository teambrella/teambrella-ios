//
//  KeychainPayTo+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainPayTo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainPayTo> {
        return NSFetchRequest<KeychainPayTo>(entityName: "KeychainPayTo")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var knownSince: NSDate?
    @NSManaged public var teammateID: Int64
    @NSManaged public var teammate: KeychainTeammate?
    @NSManaged public var output: KeychainOutput?

}
