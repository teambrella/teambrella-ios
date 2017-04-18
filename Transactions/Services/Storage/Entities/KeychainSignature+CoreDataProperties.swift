//
//  KeychainSignature+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainSignature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainSignature> {
        return NSFetchRequest<KeychainSignature>(entityName: "KeychainSignature")
    }

    @NSManaged public var id: String?
    @NSManaged public var inputID: String?
    @NSManaged public var isServerUpdateNeeded: Bool
    @NSManaged public var signature: NSData?
    @NSManaged public var teammateID: Int64
    @NSManaged public var input: KeychainInput?
    @NSManaged public var teammate: KeychainTeammate?

}
