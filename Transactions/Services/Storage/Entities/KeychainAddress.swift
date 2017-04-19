//
//  KeychainAddress.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class KeychainAddress: NSManagedObject {
    var status: UserAddressStatus { return UserAddressStatus(rawValue: Int(statusValue)) ?? .invalid }
    var teammateID: Int { return Int(teammateIDValue) }
    var address: String { return addressValue! }
    var dateCreated: Date { return dateCreatedValue! as Date }
}
