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
    
    func createOrUpdateEntities(json: JSON) {
        teams(json: json["Teams"])
        teammates(json: json["Teammates"])
        addresses(json: json["BTCAddresses"])
        transactions(json: json["Txs"])
        cosigners(json: json["Cosigners"])
        payTos(json: json["PayTos"])
        inputs(json: json["TxInputs"])
        outputs(json: json["TxOutputs"])
        signatures(json: json["TxSignatures"])
    }
    
    // Teams
    func teams(json: JSON) {
        json.arrayValue.forEach { item in
            let id = item["Id"].int64Value
            if let team = fetcher.team(id: id) {
                team.nameValue = item["Name"].stringValue
            } else {
                let team = Team(context: context)
                team.idValue = id
                team.nameValue = item["Name"].stringValue
                team.isTestnetValue = item["Testnet"].boolValue
                
                team.okAgeValue = 14
                team.autoApprovalMyGoodAddressValue = 3
                team.autoApprovalMyNewAddressValue = 7
                team.autoApprovalCosignGoodAddressValue = 3
                team.autoApprovalCosignNewAddressValue = 7
            }
        }
    }
    
    // Teammates
    func teammates(json: JSON) {
        json.arrayValue.forEach { item in
            let id = item["Id"].int64Value
            let name = item["Name"].stringValue
            let publicKey = item["PublicKey"].string
            let fbName = item["FBName"].stringValue
            let teamID = item["TeamId"].int64Value
            if let teammate = fetcher.teammate(id: id) {
                teammate.nameValue = name
            } else {
                let teammate = Teammate(context: context)
                teammate.idValue = id
                teammate.fbNameValue = fbName
                teammate.nameValue = name
                teammate.publicKeyValue = publicKey
                teammate.team = fetcher.team(id: teamID)
            }
        }
    }
    
    func addresses(json: JSON) {
        json.arrayValue.forEach { item in
            if let id = item["Address"].string, fetcher.address(id: id) == nil {
                let address = BtcAddress(context: context)
                address.addressValue = id
                let dateString = item["DateCreated"].stringValue
                if let date = formatter.date(from: dateString) {
                    address.dateCreatedValue = date as NSDate
                }
                if let status = UserAddressStatus(rawValue: item["Status"].intValue) {
                    let newStatus: UserAddressStatus!
                    switch status {
                    case .previous:
                        newStatus = .serverPrevious
                    case .current:
                        newStatus = .serverCurrent
                    case .next:
                        newStatus = .serverNext
                    default:
                        newStatus = status
                    }
                    address.statusValue = Int16(newStatus.rawValue)
                }
                address.teammate = fetcher.teammate(id: item["TeammateId"].int64Value)
            }
        }
    }
    
    func cosigners(json: JSON) {
        for item in json.arrayValue {
            let addressID = item["AddressId"].stringValue
            // TODO: check that cosigners do not have address
            //if  fetcher.address(id: addressID) != nil { continue }
            
            let cosigner = Cosigner(context: context)
            let keyOrder = item["KeyOrder"].int16Value
            let teammateID = item["TeammateId"].int64Value
            cosigner.idValue = "\(keyOrder)-\(addressID)"
            cosigner.addressIDValue = addressID
            cosigner.keyOrderValue = keyOrder
            cosigner.teammate = fetcher.teammate(id: teammateID)
        }
    }
    
    func payTos(json: JSON)  {
        json.arrayValue.forEach { item in
            let id = item["Id"].stringValue
            var payTo: PayTo!
            if let existingPayTo = fetcher.payTo(id: id) {
                payTo = existingPayTo
            } else {
                payTo = PayTo(context: context)
                payTo.addressValue = item["Address"].stringValue
                payTo.idValue = id
                payTo.isDefaultValue = item["IsDefault"].boolValue
                payTo.teammate = fetcher.teammate(id: item["TeammateId"].int64Value)
                payTo.knownSinceValue = Date() as NSDate
            }
            if payTo.isDefault {
                (payTo.teammate?.payTos as? Set<PayTo>)?.forEach { otherPayTo in
                    if otherPayTo.id != payTo.id {
                        otherPayTo.isDefaultValue = false
                    }
                }
            }
        }
    }
    
    // Txs
    // Rules for setting new current address
    // ok to set first address
    // ok to change to next address if:
    // -- no funds on existing current address
    // -- or a real Tx from current to next occurred
    func transactions(json: JSON) {
       json.arrayValue.forEach { item in
            let id = item["Id"].stringValue
            if let existingTx = fetcher.transaction(id: id) {
                existingTx.stateValue = item["State"].int16Value
                existingTx.updateTimeValue = Date() as NSDate
                existingTx.resolutionTimeValue = formatter.date(from: json["ResolutionTime"].stringValue) as NSDate?
                existingTx.processedTimeValue = formatter.date(from: json["ProcessedTime"].stringValue) as NSDate?
            } else {
                let tx = Tx(context: context)
                tx.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
                tx.claimIDValue = item["ClaimId"].int64Value
                tx.idValue = id
                if let initiatedTime = formatter.date(from: json["InitiatedTime"].stringValue) as NSDate? {
                    tx.initiatedTimeValue = initiatedTime
                }
                tx.kindValue = item["Kind"].int16Value
                tx.stateValue = item["State"].int16Value
                tx.withdrawReqIDValue = item["WithdrawReqId"].int64Value
                tx.teammate = fetcher.teammate(id: item["TeammateId"].int64Value)
                tx.claimTeammate = fetcher.teammate(id: item["ClaimTeammateId"].int64Value)
                
                tx.receivedTimeValue = Date() as NSDate
                tx.updateTimeValue = Date() as NSDate
                tx.resolutionValue = Int16(TransactionClientResolution.none.rawValue)
                tx.isServerUpdateNeededValue = false
            }
        }
    }
    
    
    // TxInputs
    func inputs(json: JSON) {
        for item in json.arrayValue {
            let id = item["Id"].stringValue
            let transactionID = item["TxId"].stringValue
            // can't change inputs
            guard fetcher.input(id: id) == nil else { continue }
            guard let tx = fetcher.transaction(id: transactionID) else { continue } // malformed TX
            
            let input = TxInput(context: context)
            input.ammountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            input.idValue = id
            input.previousTransactionIndexValue = item["PrevTxIndex"].int64Value
            input.transactionIDValue = item["TxId"].stringValue
            input.previousTransactionIDValue = item["PrevTxId"].stringValue
            
            input.transaction = tx
            //let previousTransactionID = item["PrevTxId"].stringValue
            //input.previousTransaction = BlockchainTransaction.fetch(id: previousTransactionID, in: context)
        }
    }
    
    // TxOutputs
    func outputs(json: JSON) {
        for item in json.arrayValue {
            let txID = item["TxId"].stringValue
            guard let tx = fetcher.transaction(id: txID) else { continue }
            
            let output = TxOutput(context: context)
            output.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
            output.idValue = item["Id"].stringValue
            output.payToIDValue = item["PayToId"].stringValue
            output.payTo = fetcher.payTo(id: item["PayToId"].stringValue)
            output.transactionIDValue = txID
            output.transaction = tx
        }
    }
    
    // TxSignatures
    func signatures(json: JSON) {
        for item in json.arrayValue {
            let txInputId = item["TxInputId"].stringValue
            let teammateID = item["TeammateId"].int64Value
             // can't change signatures
            guard fetcher.signature(input: txInputId,
                                    teammateID: Int(teammateID)) == nil else { continue }
            guard let txInput = fetcher.input(id: txInputId) else { continue } // malformed TX
            
            let signature = TxSignature.create(in: context)
            signature.inputIDValue = txInputId
            signature.teammateIDValue = teammateID
            signature.signatureValue = item["Signature"].stringValue.base64data as NSData?
            signature.isServerUpdateNeededValue = false
            signature.input = txInput
            
        }
    }
    
}
