//
//  PayTo.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class PayTo: NSManagedObject {
    var address: String { return addressValue! }
    var id: UUID { return UUID(uuidString: idValue!)! }
    var isDefault: Bool { return isDefaultValue }
    var knownSince: Date { return knownSinceValue! as Date }
}
