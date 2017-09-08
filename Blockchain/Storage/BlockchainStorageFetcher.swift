//
//  BlockchainStorageFetcher.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.

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

import Foundation
import CoreData

class BlockchainStorageFetcher {
    struct Constant {
        static let noAutoApproval = 1000000
        fileprivate static let tmpPrivateKey = "93ProQDtA1PyttRz96fuUHKijV3v2NGnjPAxuzfDXwFbbLBYbxx"
    }
    
    private unowned var storage: BlockchainStorage
    var context: NSManagedObjectContext { return storage.context }
    
    init(storage: BlockchainStorage) {
        self.storage = storage
    }
    
    func save() {
        storage.save()
    }
    
    // MARK: User
    var user: User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        // request.predicate = NSPredicate(format: "addressValue = %@", id)
        let result = try? context.fetch(request)
        if let user = result?.first {
            return user
        } else {
            return createUser()
        }
    }
    
    private func createUser() -> User {
        let user = User(context: context)
        //   PrivateKey = key.GetBitcoinSecret(Network.Main).ToString()
        user.privateKeyValue =  Constant.tmpPrivateKey
        save()
        return user
    }
    
    // MARK: Address
    
    func address(id: String) -> BtcAddress? {
        let request: NSFetchRequest<BtcAddress> = BtcAddress.fetchRequest()
        request.predicate = NSPredicate(format: "addressValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    // MARK: Cosigner
    
    func cosigners(for teammate: Teammate) -> [Cosigner] {
        let request: NSFetchRequest<Cosigner> = Cosigner.fetchRequest()
        request.predicate = NSPredicate(format: "teammateValue = %@", teammate)
        let result = try? context.fetch(request)
        return result ?? []
    }
    
    // MARK: Team
    
    var teams: [Team]? {
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        let items = try? context.fetch(request)
        return items
    }
    
    var firstTeam: Team? {
        return teams?.first
    }
    
    func team(id: Int64) -> Team? {
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        request.predicate = NSPredicate(format: "idValue == %i", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    // MARK: Teammate
    
    var teammates: [Teammate] {
        let request: NSFetchRequest<Teammate> = Teammate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    func teammate(id: Int64) -> Teammate? {
        let request: NSFetchRequest<Teammate> = Teammate.fetchRequest()
        request.predicate = NSPredicate(format: "idValue = %i", id)
        let items = try? context.fetch(request)
        return items?.first
    }
    
    // MARK: Transaction
    var transactions: [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        let result = try? context.fetch(request)
        return result ?? []
    }
    
    func transaction(id: String) -> Tx? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "idValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    var transactionsNeedServerUpdate: [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "isServerUpdateNeededValue == TRUE")
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    var transactionsResolvable: [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.received.rawValue)")
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    var transactionsCosignable: [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        let p1 = NSPredicate(format: "resolutionValue == %i", TransactionClientResolution.approved.rawValue)
        let p2 = NSPredicate(format: "stateValue == %i", TransactionState.selectedForCosigning.rawValue)
        let p3 = NSPredicate(format: "inputsValue.@count > 0")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    var transactionsApprovedAndCosigned: [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        let p1 = NSPredicate(format: "resolutionValue == %i", TransactionClientResolution.approved.rawValue)
        let p2 = NSPredicate(format: "stateValue == %i", TransactionState.cosigned.rawValue)
        let p3 = NSPredicate(format: "inputsValue.@count > 0")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    func transactionsChanged(since date: Date) -> [Tx]? {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = NSPredicate(format: "updateTimeValue > %@", date as NSDate)
        let items = try? context.fetch(request)
        return items
    }
    
    func isMy(tx: Tx) -> Bool {
        return tx.teammate.id == user.id
    }
    
    func isInChangeableState(tx: Tx) -> Bool {
        let unchangeableStates: Set<TransactionState> = [.errorBadRequest,
                                                         .errorCosignersTimeout,
                                                         .errorOutOfFunds,
                                                         .errorSubmitToBlockchain,
                                                         .published,
                                                         .confirmed]
        return unchangeableStates.contains(tx.state!) == false
    }
    
    func canApprove(tx: Tx) -> Bool {
        return tx.resolution == .received && isInChangeableState(tx: tx)
    }
    
    func canBlock(tx: Tx) -> Bool {
        return tx.resolution == .received && isInChangeableState(tx: tx)
    }
    
    func canUnblock(tx: Tx) -> Bool {
        return tx.resolution == .blocked && isInChangeableState(tx: tx)
    }
    
    func transactionsChangeResolution(txs: [Tx], to resolution: TransactionClientResolution, when: Date = Date()) {
        for tx in txs {
            tx.resolution = resolution
            tx.clientResolutionTimeValue = when
            tx.isServerUpdateNeeded = true
            storage.save()
        }
    }
    
    func daysToApproval(tx: Tx, isMyTx: Bool) -> Int {
        var goodPayToAddresses = true
        for txOutput in tx.outputs {
            goodPayToAddresses = goodPayToAddresses && isPayToAddressOkAge(output: txOutput)
        }
        let daysPassed = Date().interval(of: .day, since: tx.receivedTime!)
        let team = tx.teammate.team
        let autoApproval: Int!
        if isMyTx {
            autoApproval = goodPayToAddresses ? team.autoApprovalMyGoodAddress : team.autoApprovalMyNewAddress
        } else {
            autoApproval = goodPayToAddresses ? team.autoApprovalCosignGoodAddress : team.autoApprovalCosignNewAddress
        }
        return autoApproval == -1 ? Constant.noAutoApproval : autoApproval - daysPassed
    }
    
    // MARK: Input
    
    func input(id: String) -> TxInput? {
        let request: NSFetchRequest<TxInput> = TxInput.fetchRequest()
        request.predicate = NSPredicate(format: "idValue = %@", id)
        let result = try? context.fetch(request)
        return result?.first
    }
    
    // MARK: Output
    
    func isPayToAddressOkAge(output: TxOutput) -> Bool {
        let team = output.transaction.teammate.team
        let payTo = output.payTo
        
        return team.okAge <= Date().interval(of: .day, since: payTo.knownSince)
    }
    
    // MARK: PayTo
    
    func payTo(id: UUID) -> PayTo? {
        return payTo(id: id.uuidString)
    }
    
    func payTo(id: String) -> PayTo? {
        let request: NSFetchRequest<PayTo> = PayTo.fetchRequest()
        request.predicate = NSPredicate(format: "idValue = %@", id)
        let items = try? context.fetch(request)
        return items?.first
    }
    
    // MARK: Signatures
    
    var signaturesToUpdate: [TxSignature] {
        let request: NSFetchRequest<TxSignature> = TxSignature.fetchRequest()
        request.predicate = NSPredicate(format: "isServerUpdateNeededValue == TRUE")
        
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    func signature(input: UUID, teammateID: Int) -> TxSignature? {
        return signature(input: input.uuidString, teammateID: teammateID)
    }
    
    func signature(input: String, teammateID: Int) -> TxSignature? {
        let request: NSFetchRequest<TxSignature> = TxSignature.fetchRequest()
        request.predicate = NSPredicate(format: "inputValue.idValue == %@ AND teammateIDValue == %i", input, teammateID)
        let items = try? context.fetch(request)
        return items?.first
    }
    
    @discardableResult
    func addNewSignature(input: TxInput, tx: Tx, signature: Data) -> TxSignature {
        let txSignature = TxSignature.create(in: context)
        txSignature.inputValue = input
        let me = tx.teammate.team.me(user: user)
        txSignature.teammateValue = me
        txSignature.isServerUpdateNeededValue = true
        txSignature.signatureValue = signature
        save()
        return txSignature
    }
    
    
    //    var pendingPayments: [BlockchainPayTo]? {
    //        let request: NSFetchRequest<BlockchainTeammate> = BlockchainPayTo.fetchRequest()
    //        request.sortDescriptors = [NSSortDescriptor(key: "nameValue", ascending: true)]
    //        let items = try? storage.context.fetch(request)
    //        return items
    //    }
}
