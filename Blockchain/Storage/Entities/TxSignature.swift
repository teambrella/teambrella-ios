//
//  BlockchainSignature.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class TxSignature: NSManagedObject {
    var teammateID: Int { return Int(teammateIDValue) }
    var id: UUID {
        get {
        return UUID(uuidString: idValue!)!
        }
        set {
            idValue = newValue.uuidString
        }
    }
    var inputID: UUID { return UUID(uuidString:inputIDValue!)! }
    var isServerUpdateNeeded: Bool {
        get {
            return isServerUpdateNeededValue
        }
        set {
            isServerUpdateNeededValue = newValue
        }
    }
    var signature: Data { return signatureValue! as Data }
    var teammate: Teammate? { return teammateValue }
    var input: TxInput? { return inputValue }
    
    class func create(in context: NSManagedObjectContext) -> TxSignature {
        let signature = TxSignature(context: context)
        signature.id = UUID()
        return signature
    }
}
