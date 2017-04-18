//
//  KeychainTeam+CoreDataProperties.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation

extension KeychainTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeychainTeam> {
        return NSFetchRequest<KeychainTeam>(entityName: "KeychainTeam")
    }

    @NSManaged public var autoApprovalCosignGoodAddress: Int16
    @NSManaged public var autoApprovalCosignNewAddress: Int16
    @NSManaged public var autoApprovalMyGoodAddress: Int16
    @NSManaged public var autoApprovalMyNewAddress: Int16
    @NSManaged public var autoApprovalOff: Int16
    @NSManaged public var id: Int64
    @NSManaged public var isTestnet: Bool
    @NSManaged public var name: String?
    @NSManaged public var okAge: Int64
    @NSManaged public var teammates: NSSet?

}

// MARK: Generated accessors for teammates
extension KeychainTeam {

    @objc(addTeammatesObject:)
    @NSManaged public func addToTeammates(_ value: KeychainTeammate)

    @objc(removeTeammatesObject:)
    @NSManaged public func removeFromTeammates(_ value: KeychainTeammate)

    @objc(addTeammates:)
    @NSManaged public func addToTeammates(_ values: NSSet)

    @objc(removeTeammates:)
    @NSManaged public func removeFromTeammates(_ values: NSSet)

}
