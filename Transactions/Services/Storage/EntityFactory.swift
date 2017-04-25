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
    func teams(json: JSON) -> [Int64: BlockchainTeam] {
        var result: [Int64: BlockchainTeam] = [:]
         json.arrayValue.forEach { item in
            let team = BlockchainTeam(context: context)
            let id = item["Id"].int64Value
            team.idValue = id
            team.nameValue = item["Name"].stringValue
            team.isTestnetValue = item["Testnet"].boolValue
            result[id] = team
        }
        return result
    }
    
    // Teammates
    func teammates(json: JSON, teams: [Int64: BlockchainTeam]) -> [Int64: BlockchainTeammate] {
        var result: [Int64: BlockchainTeammate] = [:]
        json.arrayValue.forEach { item in
            let teammate = BlockchainTeammate(context: context)
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
    
    func addresses(json: JSON, teammates: [Int64: BlockchainTeammate]) -> [String: BlockchainAddress] {
        var result: [String: BlockchainAddress] = [:]
        json.arrayValue.forEach { item in
            let address = BlockchainAddress(context: context)
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
                   addresses: [String: BlockchainAddress],
                   teammates: [Int64: BlockchainTeammate]) -> [BlockchainCosigner] {
        var cosigners: [BlockchainCosigner] = []
        for item in json.arrayValue {
            guard let address = addresses[item["AddressId"].stringValue],
                let storedCosigners = address.cosigners,
                storedCosigners.count < 8 else { continue }
            
            let cosigner = BlockchainCosigner(context: context)
            cosigner.address = address
            cosigner.keyOrderValue = item["KeyOrder"].int16Value
            cosigner.teammate = teammates[item["TeammateId"].int64Value]
            cosigners.append(cosigner)
        }
        return cosigners
    }
    
    func payTos(json: JSON, teammates: [Int64: BlockchainTeammate]) -> [BlockchainPayTo] {
        return json.arrayValue.map { item in
            let payTo = BlockchainPayTo(context: context)
            payTo.addressValue = item["Address"].stringValue
            payTo.idValue = item["Id"].stringValue
            payTo.isDefaultValue = item["IsDefault"].boolValue
            payTo.knownSinceValue = formatter.date(from: json["KnownSince"].stringValue) as NSDate?
            payTo.teammate = teammates[item["TeammateId"].int64Value]
            return payTo
        }
    }
    
    // TxInputs
    func inputs(json: JSON) -> [BlockchainInput] {
        /* */
        return []
    }
    
    // TxOutputs
    func outputs(json: JSON) -> [BlockchainOutput] {
        return json.arrayValue.map { item in
            let output = BlockchainOutput(context: context)
            output.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            output.idValue = item["Id"].stringValue
            output.payToIDValue = item["PayToId"].stringValue
            output.transactionIDValue = item["TxId"].stringValue
            return output
        }
    }
    
    // TxSignatures
    func signatures(json: JSON) -> [BlockchainSignature] {
        /* */
        return []
    }
    
    // Txs
    func transactions(json: JSON, teammates: [Int64: BlockchainTeammate]) -> [BlockchainTransaction] {
        return json.arrayValue.map { item in
            let transaction = BlockchainTransaction(context: context)
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
