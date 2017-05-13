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
    var context: NSManagedObjectContext { return fetcher.context }
    let fetcher: BlockchainStorageFetcher
    let formatter = BlockchainDateFormatter()
    
    init(fetcher: BlockchainStorageFetcher) {
        self.fetcher = fetcher
    }
    
    // Teams
    func teams(json: JSON) -> [Int64: Team] {
        var result: [Int64: Team] = [:]
         json.arrayValue.forEach { item in
            let team = Team(context: context)
            let id = item["Id"].int64Value
            team.idValue = id
            team.nameValue = item["Name"].stringValue
            team.isTestnetValue = item["Testnet"].boolValue
            
            team.okAgeValue = 14
            team.autoApprovalMyGoodAddressValue = 3
            team.autoApprovalMyNewAddressValue = 7
            team.autoApprovalCosignGoodAddressValue = 3
            team.autoApprovalCosignNewAddressValue = 7
            
            result[id] = team
        }
        return result
    }
    
    // Teammates
    func teammates(json: JSON, teams: [Int64: Team]) -> [Int64: Teammate] {
        var result: [Int64: Teammate] = [:]
        json.arrayValue.forEach { item in
            let teammate = Teammate(context: context)
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
    
    func addresses(json: JSON, teammates: [Int64: Teammate]) -> [String: BtcAddress] {
        var result: [String: BtcAddress] = [:]
        json.arrayValue.forEach { item in
            let address = BtcAddress(context: context)
            let id = item["Address"].stringValue
            address.addressValue = id
            let dateString = item["DateCreated"].stringValue
            if let date = formatter.date(from: dateString) {
            address.dateCreatedValue = date  as NSDate
            }
            address.statusValue = item["Status"].int16Value
            address.teammate = teammates[item["TeammateId"].int64Value]
            result[id] = address
        }
        return result
    }
    
    func cosigners(json: JSON,
                   teammates: [Int64: Teammate]) -> [Cosigner] {
        var cosigners: [Cosigner] = []
        for item in json.arrayValue {
            let addressID = item["AddressId"].stringValue
            let address = fetcher.address(id: addressID)
            
            let cosigner = Cosigner(context: context)
            let keyOrder = item["KeyOrder"].int16Value
            let teammateID = item["TeammateId"].int64Value
            cosigner.idValue = "\(keyOrder)-\(addressID)"
            cosigner.address = address
            cosigner.keyOrderValue = keyOrder
            cosigner.teammate = teammates[teammateID]
            cosigners.append(cosigner)
        }
        return cosigners
    }
    
    func payTos(json: JSON, teammates: [Int64: Teammate]) -> [PayTo] {
        return json.arrayValue.map { item in
            let payTo = PayTo(context: context)
            payTo.addressValue = item["Address"].stringValue
            payTo.idValue = item["Id"].stringValue
            payTo.isDefaultValue = item["IsDefault"].boolValue
            formatter.date(from: json["KnownSince"].stringValue).map { payTo.knownSinceValue = $0 as NSDate }
            payTo.teammate = teammates[item["TeammateId"].int64Value]
            return payTo
        }
    }
    
    // Txs
    func transactions(json: JSON, teammates: [Int64: Teammate]) -> [Tx] {
        return json.arrayValue.map { item in
            let transaction = Tx(context: context)
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

    
    // TxInputs
    func inputs(json: JSON) -> [TxInput] {
        return json.arrayValue.map { item in
            let input = TxInput(context: context)
            input.ammountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            input.idValue = item["Id"].stringValue
            input.previousTransactionIndexValue = item["PrevTxIndex"].int64Value
            input.transactionIDValue = item["TxId"].stringValue
            input.previousTransactionIDValue = item["PrevTxId"].stringValue
            
            let transactionID = item["TxId"].stringValue
            input.transaction = fetcher.transaction(id: transactionID)
            //let previousTransactionID = item["PrevTxId"].stringValue
            //input.previousTransaction = BlockchainTransaction.fetch(id: previousTransactionID, in: context)
            return input
        }
    }
    
    // TxOutputs
    func outputs(json: JSON) -> [TxOutput] {
        return json.arrayValue.map { item in
            let output = TxOutput(context: context)
            output.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            output.idValue = item["Id"].stringValue
            output.payToIDValue = item["PayToId"].stringValue
            output.transactionIDValue = item["TxId"].stringValue
            return output
        }
    }
    
    // TxSignatures
    func signatures(json: JSON) -> [TxSignature] {
        /* */
        return []
    }
    
}
