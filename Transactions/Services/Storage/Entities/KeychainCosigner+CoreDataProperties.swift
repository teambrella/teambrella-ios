//
//  KeychainCosigner+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainCosigner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainCosigner> {
        return NSFetchRequest<KeychainCosigner>(entityName: "KeychainCosigner")
    }

    @NSManaged public var addressID: String?
    @NSManaged public var keyOrder: Int16
    @NSManaged public var teammateID: Int64
    @NSManaged public var address: KeychainAddress?
    @NSManaged public var teammate: KeychainTeammate?

}
