//
//  KeychainCosigner.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class KeychainCosigner: NSManagedObject {
    var keyOrder: Int { return Int(keyOrderValue) }
    var teammateID: Int { return Int(teammateIDValue) }
    var addressID: String { return addressIDValue! }
}
