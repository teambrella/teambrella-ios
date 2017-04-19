//
//  EntityFactory.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

struct EntityFactory {
    let context: NSManagedObjectContext
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // Teams
    func teams(json: JSON) -> [Int64: KeychainTeam] {
        var result: [Int64: KeychainTeam] = [:]
         json.arrayValue.forEach { item in
            let team = KeychainTeam(context: context)
            let id = item["Id"].int64Value
            team.idValue = id
            team.nameValue = item["Name"].stringValue
            team.isTestnetValue = item["Testnet"].boolValue
            result[id] = team
        }
        return result
    }
    
    // Teammates
    func teammates(json: JSON, teams: [Int64: KeychainTeam]) -> [Int64: KeychainTeammate] {
        var result: [Int64: KeychainTeammate] = [:]
        json.arrayValue.forEach { item in
            let teammate = KeychainTeammate(context: context)
            let id = item["Id"].int64Value
            teammate.idValue = id
            teammate.fbNameValue = item["FBName"].stringValue
            teammate.nameValue = item["Name"].stringValue
            teammate.publicKeyValue = item["PublicKey"].string
            teammate.team = teams[item["TeamId"].int64Value]
            result[id] = teammate
        }
        return result
    }
    
    func addresses(json: JSON, teammates: [Int64: KeychainTeammate]) -> [String: KeychainAddress] {
        var result: [String: KeychainAddress] = [:]
        json.arrayValue.forEach { item in
            let address = KeychainAddress(context: context)
            let id = item["Address"].stringValue
            address.addressValue = id
            address.dateCreatedValue = formatter.date(from: item["DateCreated"].stringValue) as NSDate?
            address.statusValue = item["Status"].int16Value
            address.teammate = teammates[item["TeammateId"].int64Value]
            result[id] = address
        }
        return result
    }
    
    func cosigners(json: JSON,
                   addresses: [String: KeychainAddress],
                   teammates: [Int64: KeychainTeammate]) -> [KeychainCosigner] {
        return json.arrayValue.map { item in
            let cosigner = KeychainCosigner(context: context)
            let address = item["AddressId"].stringValue
            cosigner.address = addresses[address]
            cosigner.keyOrderValue = item["KeyOrder"].int16Value
            cosigner.teammate = teammates[item["TeammateId"].int64Value]
            return cosigner
        }
    }
    
    func payTos(json: JSON, teammates: [Int64: KeychainTeammate]) -> [KeychainPayTo] {
        return json.arrayValue.map { item in
            let payTo = KeychainPayTo(context: context)
            payTo.addressValue = item["Address"].stringValue
            payTo.idValue = item["Id"].stringValue
            payTo.isDefaultValue = item["IsDefault"].boolValue
            payTo.knownSinceValue = formatter.date(from: json["KnownSince"].stringValue) as NSDate?
            payTo.teammate = teammates[item["TeammateId"].int64Value]
            return payTo
        }
    }
    
    // TxInputs
    func inputs(json: JSON) -> [KeychainInput] {
        /* */
        return []
    }
    
    // TxOutputs
    func outputs(json: JSON) -> [KeychainOutput] {
        return json.arrayValue.map { item in
            let output = KeychainOutput(context: context)
            output.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            output.idValue = item["Id"].stringValue
            output.payToIDValue = item["PayToId"].stringValue
            output.transactionIDValue = item["TxId"].stringValue
            return output
        }
    }
    
    // TxSignatures
    func signatures(json: JSON) -> [KeychainSignature] {
        /* */
        return []
    }
    
    // Txs
    func transactions(json: JSON, teammates: [Int64: KeychainTeammate]) -> [KeychainTransaction] {
        return json.arrayValue.map { item in
            let transaction = KeychainTransaction(context: context)
            transaction.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            transaction.claimIDValue = item["ClaimId"].int64Value
            transaction.idValue = item["Id"].stringValue
            if let initiatedTime = formatter.date(from: json["InitiatedTime"].stringValue) as NSDate? {
            transaction.initiatedTimeValue = initiatedTime
            }
            transaction.kindValue = item["Kind"].int16Value
            transaction.stateValue = item["State"].int16Value
            transaction.withdrawReqIDValue = item["WithdrawReqId"].int64Value
            transaction.teammate = teammates[item["TeammateId"].int64Value]
            transaction.claimTeammate = teammates[item["ClaimTeammateId"].int64Value]
            return transaction
        }
    }
    
}
