//
//  BtcAddress.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class BtcAddress: NSManagedObject {
    var status: UserAddressStatus { return UserAddressStatus(rawValue: Int(statusValue)) ?? .invalid }
    var address: String { return addressValue! }
    var dateCreated: Date { return dateCreatedValue! as Date }
    
}

extension BtcAddress {
    class func fetch(id: String, in context: NSManagedObjectContext) -> BtcAddress? {
        let request: NSFetchRequest<BtcAddress> = BtcAddress.fetchRequest()
        request.predicate = NSPredicate(format: "addressValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
}
