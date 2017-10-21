//
//  EntityFactory.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import CoreData
import Foundation
import SwiftyJSON

struct EntityFactory {
    var context: NSManagedObjectContext
    let fetcher: BlockchainStorageFetcher
    let formatter = BlockchainDateFormatter()
    
    init(fetcher: BlockchainStorageFetcher) {
        self.fetcher = fetcher
        self.context = fetcher.context
    }
    
    func updateLocalDb(txs: [Tx], signatures: [TxSignature], json: JSON) {
        txs.forEach { tx in tx.isServerUpdateNeeded = false }
        signatures.forEach { signature in signature.isServerUpdateNeeded = false }
        
        createAndUpdate(with: json)
        check(with: json)
        connectEntities(with: json)
    }
    
    private func createAndUpdate(with json: JSON) {
        teams(json: json["Teams"])
        teammates(json: json["Teammates"])
        payTos(json: json["PayTos"])
        addresses(json: json["BTCAddresses"])
        cosigners(json: json["Cosigners"])
        transactions(json: json["Txs"])
        inputs(json: json["TxInputs"])
        outputs(json: json["TxOutputs"])
        signatures(json: json["TxSignatures"])
        multisig(json: json["Multisigs"])
        fetcher.save()
    }
    
    private func check(with json: JSON) {
        let txs = json["Txs"].arrayValue
        for arrivingTx in txs {
            guard let tx = self.fetcher.transaction(id: arrivingTx["Id"].stringValue) else { continue }
            
            let isWalletToMove = tx.kind == .moveToNextWallet || tx.kind == .saveFromPreviousWallet
            // Outputs are required unless it's a wallet update
                if isWalletToMove == false && tx.outputs.isEmpty {
                    fetcher.transactionsChangeResolution(txs: [tx], to: .errorBadRequest)
                    continue
                }
             // AmountBTC sum must match total unless it's a wallet update
            if isWalletToMove == false {
                let outputsSum = tx.outputs.reduce(0) { $0 + $1.amount }
                if abs(outputsSum - tx.amount) > 0.000001 {
                    fetcher.transactionsChangeResolution(txs: [tx], to: .errorBadRequest)
                }
                
            }
            
            if tx.resolution == .none {
                fetcher.transactionsChangeResolution(txs: [tx], to: .received)
            }
        }
        
        let addresses = json["BTCAddresses"].arrayValue
        for address in addresses {
            if let addressSaved = fetcher.address(id: address["Address"].stringValue) {
                let generatedAddress = SignHelper.generateStringAddress(from: addressSaved)
                if generatedAddress != addressSaved.address {
                    print("Address mismatch gen: \(generatedAddress), received: \(addressSaved.address)")
                    addressSaved.status = .invalid
                } else {
                    print("Address OK! \(generatedAddress)")
                }
            }
            
        }
        
    }
    
    private func connectEntities(with json: JSON) {
        
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
                teammate.teamValue = fetcher.team(id: teamID)
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
                    address.dateCreatedValue = date
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
                address.teammateValue = fetcher.teammate(id: item["TeammateId"].int64Value)
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
            cosigner.teammateValue = fetcher.teammate(id: teammateID)
            cosigner.addressValue = fetcher.address(id: addressID)
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
                payTo.teammateValue = fetcher.teammate(id: item["TeammateId"].int64Value)
                payTo.knownSinceValue = Date()
            }
            if payTo.isDefault {
                payTo.teammate.payTos.forEach { otherPayTo in
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
                existingTx.updateTimeValue = Date()
                existingTx.resolutionTimeValue = formatter.date(from: item, key: "ResolutionTime")
                existingTx.processedTimeValue = formatter.date(from: item, key: "ProcessedTime")
            } else {
                let tx = Tx(context: context)
                tx.amountValue = Decimal(item["AmountBTC"].doubleValue) as NSDecimalNumber
                tx.claimIDValue = item["ClaimId"].int64Value
                tx.idValue = id
                tx.initiatedTimeValue = formatter.date(from: item, key: "InitiatedTime")
                tx.kindValue = item["Kind"].int16Value
                tx.stateValue = item["State"].int16Value
                tx.withdrawReqIDValue = item["WithdrawReqId"].int64Value
                tx.teammateValue = fetcher.teammate(id: item["TeammateId"].int64Value)
                tx.claimTeammateValue = fetcher.teammate(id: item["ClaimTeammateId"].int64Value)
                
                tx.receivedTimeValue = Date()
                tx.updateTimeValue = Date()
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
            
            input.transactionValue = tx
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
            output.payToValue = fetcher.payTo(id: item["PayToId"].stringValue)
            output.transactionIDValue = txID
            output.transactionValue = tx
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
            signature.signatureValue = item["Signature"].stringValue.base64data
            signature.isServerUpdateNeededValue = false
            signature.inputValue = txInput
            signature.teammateValue = fetcher.teammate(id: teammateID)
        }
    }
    
    func multisig(json: JSON) {
        for item in json.arrayValue {
            let id =  item["id"].int64Value
            let existing = fetcher.multisig(id: id)
            let isNew = existing == nil
            let multisig = existing ?? Multisig(context: context)
            multisig.idValue = id
            multisig.addressValue = item["address"].string
            multisig.creationTxValue = item["creationTx"].string
            multisig.teammateIdValue = item["teammateId"].int64Value
            multisig.statusValue = item["status"].int32Value
            multisig.dateCreatedValue = formatter.date(from: item, key: "dateCreated")
            multisig.teammateNameValue = item["teammateName"].string
            multisig.teammatePublicKeyValue = item["teammatePublicKey"].string
            multisig.teamIdValue = item["teamId"].int64Value
        }
    }
    
}
