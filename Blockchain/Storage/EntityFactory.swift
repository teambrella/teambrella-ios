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
import ExtensionsPack
import Foundation

struct EntityFactory {
    var context: NSManagedObjectContext
    let fetcher: TeambrellaContentProvider
    let formatter = BlockchainDateFormatter()
    
    init(fetcher: TeambrellaContentProvider) {
        self.fetcher = fetcher
        self.context = fetcher.context
    }

    func updateLocalDb(txs: [Tx], signatures: [TxSignature], multisigs: [Multisig], serverUpdate: UpdatesServerImpl) {
        txs.forEach { tx in tx.isServerUpdateNeeded = false }
        signatures.forEach { signature in signature.isServerUpdateNeeded = false }
        multisigs.forEach { multisig in multisig.needServerUpdate = false }

        createAndUpdate(with: serverUpdate)
        check(with: serverUpdate)
        connectEntities(with: serverUpdate)
    }

    func createAndUpdate(with serverUpdate: UpdatesServerImpl) {
        update(teams: serverUpdate.teams)
        update(teammates: serverUpdate.teammates)
        update(payTos: serverUpdate.payTos)
        update(txs: serverUpdate.txs)
        update(inputs: serverUpdate.txInputs)
        update(outputs: serverUpdate.txOutputs)
        update(signatures: serverUpdate.txSignatures)
        update(multisigs: serverUpdate.multisigs)
        update(cosigners: serverUpdate.cosigners)
        fetcher.save()
    }

    func check(with update: UpdatesServerImpl) {
        let txs = update.txs
        for arrivingTx in txs {
            guard let tx = self.fetcher.transaction(id: arrivingTx.id) else { continue }

            let isWalletToMove = tx.kind == .moveToNextWallet || tx.kind == .saveFromPreviousWallet
            // Outputs are required unless it's a wallet update
            if isWalletToMove == false && tx.outputs.isEmpty {
                fetcher.transactionsChangeResolution(txs: [tx], to: .errorBadRequest)
                continue
            }
            // AmountCrypto sum must match total unless it's a wallet update
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

        /*
         let addresses = json["CryptoAddresses"].arrayValue
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
         */
    }

    func connectEntities(with: UpdatesServerImpl) {

    }

    func update(teams: [TeamServerImpl]) {
        teams.forEach { item in
            let id = item.id
            if let team = fetcher.team(id: id) {
                team.nameValue = item.name
            } else {
                let team = Team(context: context)
                team.idValue = id
                team.nameValue = item.name
                team.isTestnetValue = item.isTestnet

                team.okAgeValue = 14
                team.autoApprovalMyGoodAddressValue = 3
                team.autoApprovalMyNewAddressValue = 7
                team.autoApprovalCosignGoodAddressValue = 3
                team.autoApprovalCosignNewAddressValue = 7
            }
        }
    }

    func update(teammates: [TeammateServerImpl]) {
        teammates.forEach { item in
            let id = item.id
            let name = item.name
            let publicKey = item.publicKey
            let fbName = item.fbName
            let teamID = item.teamID
            let cryptoAddress = item.cryptoAddress
            let socialName = item.socialName
            
            if let teammate = fetcher.teammate(id: id) {
                teammate.nameValue = name
            } else {
                let teammate = Teammate(context: context)
                teammate.idValue = id
                teammate.fbNameValue = fbName
                teammate.nameValue = name
                teammate.publicKeyValue = publicKey
                teammate.cryptoAddressValue = cryptoAddress
                teammate.socialNameValue = socialName

                teammate.teamValue = fetcher.team(id: teamID)
            }
        }
    }

    func update(payTos: [PayToServerImpl]) {
        payTos.forEach { item in
            let id = item.id
            var payTo: PayTo!
            if let existingPayTo = fetcher.payTo(id: id) {
                payTo = existingPayTo
            } else {
                payTo = PayTo(context: context)
                payTo.addressValue = item.address
                payTo.idValue = id
                payTo.isDefaultValue = item.isDefault
                payTo.knownSinceValue = Date()

                payTo.teammateValue = fetcher.teammate(id: item.teammateID)
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

    func update(txs: [TxServerImpl]) {
        txs.forEach { item in
            let id = item.id
            if let existingTx = fetcher.transaction(id: id) {
                existingTx.stateValue = item.state
                existingTx.updateTimeValue = Date()
                existingTx.resolutionTimeValue = nil//formatter.date(from: item.re)
                existingTx.processedTimeValue = nil//formatter.date(from: item, key: "ProcessedTime")
            } else {
                let tx = Tx(context: context)
                tx.amountValue = item.amountCrypto as NSDecimalNumber
                tx.claimIDValue = item.claimID ?? 0
                tx.idValue = id
                tx.initiatedTimeValue = formatter.date(from: item.initiatedTime)
                tx.kindValue = item.kind
                tx.stateValue = item.state
                tx.withdrawReqIDValue = item.withdrawReqID ?? 0

                tx.teammateValue = fetcher.teammate(id: item.teammateID)
                if let claimTeammateID = item.claimTeammateID {
                    tx.claimTeammateValue = fetcher.teammate(id: claimTeammateID)
                }

                tx.receivedTimeValue = Date()
                tx.updateTimeValue = Date()
                tx.resolutionValue = Int16(TransactionClientResolution.none.rawValue)
                tx.isServerUpdateNeededValue = false
            }
        }
    }

    func update(inputs: [TxInputServerImpl]) {
        for item in inputs {
            let id = item.id
            let transactionID = item.txID
            // can't change inputs
            guard fetcher.input(id: id) == nil else { continue }
            guard let tx = fetcher.transaction(id: transactionID) else { continue } // malformed TX

            let input = TxInput(context: context)
            input.ammountValue = item.amountCrypto as NSDecimalNumber
            input.idValue = id
            input.previousTransactionIndexValue = item.prevTxIndex
            input.transactionIDValue = item.txID
            input.previousTransactionIDValue = item.prevTxID

            input.transactionValue = tx
            //let previousTransactionID = item["PrevTxId"].stringValue
            //input.previousTransaction = BlockchainTransaction.fetch(id: previousTransactionID, in: context)
        }
    }

    func update(outputs: [TxOutputServerImpl]) {
        for item in outputs {
            let txID = item.txID
            guard let tx = fetcher.transaction(id: txID) else { continue }

            let output = TxOutput(context: context)
            output.amountValue = item.amountCrypto as NSDecimalNumber
            output.idValue = item.id
            output.payToIDValue = item.payToID
            output.payToValue = fetcher.payTo(id: item.payToID)
            output.transactionIDValue = txID
            output.transactionValue = tx
        }
    }

    func update(signatures: [TxSignatureServerImpl]) {
        for item in signatures {
            let txInputID = item.txInputID
            let teammateID = item.teammateID

            // can't change signatures
            if let sig = fetcher.signature(input: txInputID,
                                           teammateID: Int(teammateID)) {
                sig.isServerUpdateNeededValue = false
                continue
            }
            guard let txInput = fetcher.input(id: txInputID) else { continue } // malformed TX

            let signature = TxSignature.create(in: context)
            signature.inputIDValue = txInputID
            signature.teammateIDValue = teammateID
            signature.signatureValue = item.signature.base64data
            signature.isServerUpdateNeededValue = false
            signature.inputValue = txInput

            signature.teammateValue = fetcher.teammate(id: teammateID)
        }
    }

    func update(multisigs: [MultisigServerImpl]) {
        multisigs.forEach { item in
            let id =  item.id
            let existing = fetcher.multisig(id: id)
            let multisig = existing ?? Multisig(context: context)
            multisig.idValue = id
            multisig.addressValue = item.address
            multisig.creationTxValue = nil //item[" CreationTx"].string
            multisig.statusValue = item.status
            multisig.dateCreatedValue = formatter.date(from: item.dateCreated)

            let teammate = fetcher.teammate(id: item.teammateID)
            multisig.teammateValue = teammate
        }
    }

    func update(cosigners: [CosignerServerImpl]) {
        cosigners.forEach { item in
            let cosigner = Cosigner(context: context)
            let keyOrder = item.keyOrder
            let teammateID = item.teammateID    
            let multisigID = item.multisigID
            cosigner.idValue = "\(teammateID)-\(multisigID)-\(keyOrder)"
            cosigner.keyOrderValue = keyOrder
            cosigner.multisigIDValue = multisigID

            cosigner.teammateValue = fetcher.teammate(id: teammateID)
            cosigner.multisigValue = fetcher.multisig(id: multisigID)
        }
    }
    
}
