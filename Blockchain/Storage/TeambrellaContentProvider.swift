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

class TeambrellaContentProvider {
    struct Constant {
        static let noAutoApproval = 1000000
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
        let result = try? context.fetch(request)
        if let user = result?.first {
            return user
        } else {
            return createUser()
        }
    }
    
    private func createUser() -> User {
        let user = User(context: context)
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
    
    func transactions(with predicate: NSPredicate) -> [Tx] {
        let request: NSFetchRequest<Tx> = Tx.fetchRequest()
        request.predicate = predicate
        let result = try? context.fetch(request)
        return result ?? []
    }
    
    func transaction(id: String) -> Tx? {
        return transactions(with: NSPredicate(format: "idValue = %@", id)).first
    }
    
    var transactionsNeedServerUpdate: [Tx] {
        return transactions(with: NSPredicate(format: "isServerUpdateNeededValue == TRUE"))
    }
    
    var transactionsResolvable: [Tx] {
        let predicate = NSPredicate(format: "resolutionValue == \(TransactionClientResolution.received.rawValue)")
        return transactions(with: predicate)
    }
    
    var transactionsCosignable: [Tx] {
        let predicates = [NSPredicate(format: "resolutionValue == %i", TransactionClientResolution.approved.rawValue),
                          NSPredicate(format: "stateValue == %i", TransactionState.selectedForCosigning.rawValue),
                          NSPredicate(format: "inputsValue.@count > 0")
        ]
        return transactions(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    var transactionsApprovedAndCosigned: [Tx] {
        let predicates = [NSPredicate(format: "resolutionValue == %i", TransactionClientResolution.approved.rawValue),
                          NSPredicate(format: "stateValue == %i", TransactionState.cosigned.rawValue),
                          NSPredicate(format: "inputsValue.@count > 0")
        ]
        return transactions(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    func transactionsChanged(since date: Date) -> [Tx]? {
        return transactions(with: NSPredicate(format: "updateTimeValue > %@", date as NSDate))
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
        return signatures(with: NSPredicate(format: "isServerUpdateNeededValue == TRUE"))
    }
    
    func signatures(with predicate: NSPredicate) -> [TxSignature] {
        let request: NSFetchRequest<TxSignature> = TxSignature.fetchRequest()
        request.predicate = predicate
        let items = try? context.fetch(request)
        return items ?? []
    }
    
    func signature(input: UUID, teammateID: Int) -> TxSignature? {
        return signature(input: input.uuidString, teammateID: teammateID)
    }
    
    func signature(input: String, teammateID: Int) -> TxSignature? {
        let predicates = [NSPredicate(format: "inputValue.idValue == %@", input),
                          NSPredicate(format: "teammateIDValue == %i", teammateID)
        ]
        return signatures(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).first
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
    
    // MARK: Multisig
    
    func multisig(id: Int64) -> Multisig? {
        return multisigs(with: NSPredicate(format: "idValue = %i", id)).first
    }
    
    func multisigsToCreate(publicKey: String) -> [Multisig] {
        let predicates = [NSPredicate(format: "addressValue = nil"),
                          NSPredicate(format: "statusValue = %i", MultisigStatus.current.rawValue),
                          NSPredicate(format: "publicKeyValue = %@", publicKey)
        ]
        return multisigs(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    /// get multisigs with address by teammate id
    func multisigs(publicKey: String, teammateID: Int64) -> [Multisig] {
        let predicates = [NSPredicate(format: "publicKeyValue = %@", publicKey),
                          NSPredicate(format: "teammateIdValue = %i", teammateID),
                          NSPredicate(format: "addressValue != nil"),
                          NSPredicate(format: "creationTxValue != nil")
        ]
        return multisigs(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    func multisigsInCreation(publicKey: String) -> [Multisig] {
        let predicates = [NSPredicate(format: "publicKeyValue = %@", publicKey),
                          NSPredicate(format: "addressValue = nil"),
                          NSPredicate(format: "creationTxValue != nil"),
                          NSPredicate(format: "statusValue != %i", MultisigStatus.failed.rawValue)
        ]
        return multisigs(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    func currentMultisigsWithAddress(publicKey: String) -> [Multisig] {
        let predicates = [NSPredicate(format: "publicKeyValue = %@", publicKey),
                          NSPredicate(format: "addressValue != nil"),
                          NSPredicate(format: "statusValue != %i", MultisigStatus.current.rawValue)
        ]
        return multisigs(with: NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
    }
    
    func multisigs(with predicate: NSPredicate) -> [Multisig] {
        let request: NSFetchRequest<Multisig> = Multisig.fetchRequest()
        request.predicate = predicate
        let items = try? context.fetch(request)
        return items ?? []
    }
    
}
