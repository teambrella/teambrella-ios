//
//  TeambrellaService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.

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

final class TeambrellaService: NSObject {
    struct Constant {
        static let maxAttempts = 3
        static let gasLimit = 1300001
    }
    
    var key: Key { return Key(base58String: self.contentProvider.user.privateKey(in: keyStorage),
                              timestamp: self.server.timestamp)
    }
    var isStorageCleared = false {
        didSet {
            if isStorageCleared {
                queue.cancelAllOperations()
            }
        }
    }

    private let dispatchQueue = DispatchQueue(label: "com.teambrella.teambrellaService.queue", qos: .background)
    private let server = BlockchainServer()
    private let keyStorage: KeyStorage = KeyStorage.shared
    lazy private var contentProvider: TeambrellaContentProvider = TeambrellaContentProvider(keyStorage: self.keyStorage)
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    private var currentAttempt = 0
    private var hasChanges: Bool = true
    lazy private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.teambrella.teambrellaService.operationQueue"
        // make this queue serial
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = dispatchQueue
        return queue
    }()
    lazy var processor: EthereumProcessor = EthereumProcessor(key: contentProvider.user.key(in: self.keyStorage))
    lazy private var wallet: EthWallet = { EthWallet(isTestNet: server.isTestnet, processor: processor) }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startUpdating(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        sync(completion: completion)
    }

    func clear() throws {
        try contentProvider.clear()
        isStorageCleared = true
    }

    #if MAIN_APP
    func signToSockets(service: SocketService) {
        log("Teambrella service signing to socket", type: .cryptoDetails)
        service.add(listener: self) { [weak self] action in
            switch action.command {
            case .dbDump:
                self?.sendDBDump()
            default:
                break
            }
        }
    }
    #endif

    func sendDBDump() {
        let dumper = Dumper(api: self.server)
        dumper.sendDatabaseDump(privateKey: self.key.privateKey)
    }

    func approve(tx: Tx) {
        contentProvider.transactionsChangeResolution(txs: [tx], to: .approved)
    }

    // MARK: Private

    private func update(completion: @escaping (Bool) -> Void) {
        log("Teambrella service begins updates", type: .crypto)
        // let blockchain = BlockchainService(contentProvider: contentProvider, server: server)
        updateData { success in
            if success {
                //  blockchain.updateData()
                self.contentProvider.save()
            }

            if self.hasChanges && self.currentAttempt < Constant.maxAttempts {
                self.currentAttempt += 1
                log("Teambrella has more things to update. Requesting update attempt: \(self.currentAttempt)\n\n",
                    type: .crypto)
                self.update(completion: completion)
            } else {
                self.currentAttempt = 0
                self.hasChanges = false
                completion(success)
            }
        }
        
    }
    
    private func updateData(completion: @escaping (Bool) -> Void) {
        server.initTimestamp { (timestamp, error) in
            if let error = error {
                log("Update data couldn't proceed because of failed timestamp \(error)", type: .error)
                completion(false)
                return
            }

            self.autoApproveTransactions()
            self.serverUpdateToLocalDb { success in
                    completion(success)
            }
        }
    }

    private func serverUpdateToLocalDb(completion: @escaping (Bool) -> Void) {
        let txsToUpdate = contentProvider.transactionsNeedServerUpdate
        let signatures = contentProvider.signaturesToUpdate
        let user = contentProvider.user
        let multisigsToUpdate = contentProvider.multisigsNeedsServerUpdate

        hasChanges = !(txsToUpdate.isEmpty && signatures.isEmpty && multisigsToUpdate.isEmpty)

        server.getUpdates(privateKey: user.privateKey(in: keyStorage),
                          lastUpdated: user.lastUpdated,
                          multisigs: multisigsToUpdate,
                          transactions: txsToUpdate,
                          signatures: signatures
        ) { [unowned self] updates, error in
            guard !self.isStorageCleared,
                let updates = updates else {
                    completion(false)
                    return
            }

            log("BlockchainStorage Server update to local db received updates: \(updates)", type: .cryptoRequests)
            let factory = EntityFactory(fetcher: self.contentProvider)
            factory.updateLocalDb(txs: txsToUpdate,
                                  signatures: signatures,
                                  multisigs: multisigsToUpdate,
                                  serverUpdate: updates.updates)
            user.lastUpdated = updates.updates.lastUpdated
            self.contentProvider.save()
            completion(true)
        }
    }
    
    private func autoApproveTransactions() {
        let txs = contentProvider.transactionsToApprove
        for tx in txs {
            let daysLeft = contentProvider.daysToApproval(tx: tx, isMyTx: contentProvider.isMy(tx: tx))
            if daysLeft <= 0 {
                tx.resolution = .approved
                tx.isServerUpdateNeeded = true
            }
        }
        contentProvider.save()
    }
    
    private func sync(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        log("Teambrella service start sync", type: .cryptoDetails)
        log("Public Key: \(key.publicKey)", type: .cryptoDetails)
        isStorageCleared = false
        registerBackgroundTaskIfNeeded(completion: completion)
        queue.addOperation {
            //self.queue.isSuspended = true
            self.createWallets(gasLimit: Constant.gasLimit, completion: { success in
                log("wallet created \(success)", type: .crypto)
                //self.queue.isSuspended = false
            })
        }
        
        queue.addOperation {
            //self.queue.isSuspended = true
            self.verifyIfWalletIsCreated(gasLimit: Constant.gasLimit) { success in
                log("wallet creation verified: \(success)", type: .crypto)
               // self.queue.isSuspended = false
            }
        }
        
        queue.addOperation {
            self.depositWallet()
        }
        
        queue.addOperation {
            self.autoApproveTxs()
        }
        
        queue.addOperation {
            do {
                try self.cosignApprovedTransactions()
            } catch {
                log("Error cosigning approved transactions: \(error)", type: [.error, .crypto])
            }
        }
        
        queue.addOperation {
            self.masterSign()
        }
        
        queue.addOperation {
            self.publishApprovedAndCosignedTxs()
        }
        
        queue.addOperation {
            self.queue.isSuspended = true
            self.update() { _ in
                self.queue.isSuspended = false
            }
        }
        
        queue.addOperation {
            log("Teambrella service executed all sync operations", type: .crypto)
            self.endBackgroundTaskIfNeeded(result: .newData, completion: completion)
        }
        
    }
    
    private func createWallets(gasLimit: Int, completion: @escaping (Bool) -> Void) {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let myPublicKey = key.publicKey
        let multisigsToCreate = contentProvider.multisigsToCreate(publicKey: myPublicKey)
        guard !multisigsToCreate.isEmpty else {
            completion(false)
            return
        }
        
        // let wallet = EthWallet(isTestNet: server.isTestnet, processor: processor)
        wallet.checkMyNonce(success: { [weak self] nonce in
            guard let `self` = self else { return }
            var nonce = nonce
            
            let group = DispatchGroup()
            var success = false
            for multisig in multisigsToCreate {
                if let sameMultisig = self.myTeamMultisigIfAny(publicKey: myPublicKey,
                                                               myTeammateID: multisig.teammate?.id ?? 0,
                                                               multisigs: multisigsToCreate) {
                    log("same multisig: \(sameMultisig)", type: .cryptoDetails)
                    // todo: move "cosigner list", and send to the server the move tx (not creation tx).
                    ////boolean needServerUpdate = (sameTeammateMultisig.address != null);
                    ////operations.add(mTeambrellaClient.setMutisigAddressTxAndNeedsServerUpdate(m,
                    //                                                      sameTeammateMultisig.address,
                    //                                                      sameTeammateMultisig.creationTx,
                    //                                                      needServerUpdate));
                } else {
                    group.enter()
                    var gasPrice = 0
                    self.wallet.refreshContractCreationGasPrice { contractGasPrice in
                        gasPrice = contractGasPrice
                        group.leave()
                    }

                    group.enter()
                    self.wallet.createOneWallet(myNonce: nonce,
                                                multisig: multisig,
                                                gaslLimit: gasLimit,
                                                gasPrice: gasPrice,
                                                completion: { txHex in
                                                    // There could be 2 my pending mutisigs
                                                    // (Current and Next) for the same
                                                    // team. So we remember the first creation tx and
                                                    // don't create 2 contracts for the same team.
                                                    multisig.creationTx = txHex
                                                    multisig.needServerUpdate = false
                                                    multisig.address = nil
                                                    self.contentProvider.createUnconfirmed(multisigId: multisig.id,
                                                                                           tx: txHex,
                                                                                           gasPrice: gasPrice,
                                                                                           nonce: nonce,
                                                                                           date: Date())
                                                    self.contentProvider.save()
                                                    nonce += 1
                                                    success = true
                                                    group.leave()
                    }, failure: { error in
                        completion(false)
                    })
                }
                group.wait()
            }
            completion(success)
        }) { error in
            completion(false)
        }
    }
    
    private func verifyIfWalletIsCreated(gasLimit: Int, completion: (Bool) -> Void) {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let publicKey = key.publicKey
        let creationTxs = contentProvider.multisigsInCreation(publicKey: publicKey)
        var success = !creationTxs.isEmpty
        let group = DispatchGroup()
        
        for multisig in creationTxs {
            let oldUnconfirmed = contentProvider.unconfirmed(multisigId: multisig.id, txHash: multisig.creationTx!)
            multisig.unconfirmed = oldUnconfirmed
            group.enter()
            wallet.validateCreationTx(multisig: multisig, gasLimit: gasLimit, success: { [weak self] address in
                multisig.address = address
                multisig.needServerUpdate = true
                self?.contentProvider.save()
                group.leave()
                }, notmined: { [weak self] gasLimit in
                    self?.recreateWalletIfTimedOut(multisig: multisig, gasLimit: gasLimit, completion: { innerSuccees in
                        success = false
                        group.leave()
                    })
                }, failure: { error in
                    success = false
                    group.leave()
            })
            group.wait()
        }
        completion(success)
    }
    
    private func recreateWalletIfTimedOut(multisig: Multisig, gasLimit: Int, completion: @escaping (Bool) -> Void) {
        guard let unconfirmed = multisig.unconfirmed else {
            completion(false)
            return
        }
        guard let unconfirmedDate = unconfirmed.dateCreated else {
            completion(false)
            return
        }
        let timeout = NSCalendar.current.date(byAdding: .hour, value: -12, to: NSDate() as Date)!
        if unconfirmedDate >= timeout  {
            completion(false)
            return
        }
        
        let betterGasPrice = getBetterGasPriceForContractCreation(oldPrice: unconfirmed.cryptoFee)
        
        self.wallet.createOneWallet(myNonce: unconfirmed.cryptoNonce,
                                    multisig: multisig,
                                    gaslLimit: gasLimit,
                                    gasPrice: betterGasPrice,
                                    completion: { recreatedTxHash in
                                        let newUnconfirmed = self.contentProvider
                                            .createUnconfirmed(multisigId: multisig.id,
                                                               tx: recreatedTxHash,
                                                               gasPrice: betterGasPrice,
                                                               nonce: unconfirmed.cryptoNonce,
                                                               date: Date())
                                        multisig.creationTx = recreatedTxHash
                                        multisig.unconfirmed = newUnconfirmed
                                        multisig.needServerUpdate = false
                                        self.contentProvider.save()
                                        completion(true)
        }, failure: { error in
            completion(false)
        })
    }
    
    private func depositWallet() {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let publicKey = key.publicKey
        let myCurrentMultisigs = contentProvider.currentMultisigsWithAddress(publicKey: publicKey)
        if let multisig = myCurrentMultisigs.first {
            wallet.deposit(multisig: multisig) { success in
                log("Wallet deposit result: \(success)", type: .crypto)
            }
        }
        
    }
    
    private func autoApproveTxs() {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let txs = contentProvider.transactionsToApprove
        log("Teambrella service has \(txs.count) transactions to approve", type: .crypto)
        contentProvider.transactionsChangeResolution(txs: txs, to: .approved, when: Date())
    }
    
    private func cosignApprovedTransactions() throws {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let list = contentProvider.transactionsCosignable
        log("Teambrella service has \(list.count) cosignable transactions", type: .crypto)
        let user = contentProvider.user
        for tx in list {
            try cosignTransaction(transaction: tx, userID: user.id)
        }
    }

    private func cosignTransaction(transaction: Tx, userID: Int) throws {
        guard let kind = transaction.kind else { return }

        switch kind {
        case .payout, .withdraw, .moveToNextWallet:
            guard transaction.fromMultisig != nil else { return }

            for input in transaction.inputs {
                let signature = try wallet.cosign(transaction: transaction, payOrMoveFrom: input)
                contentProvider.addNewSignature(input: input, tx: transaction, signature: signature)
            }
            contentProvider.transactionsChangeResolution(txs: [transaction], to: .signed)
        default:
            // TODO: support move & incoming TXs
            break
        }
    }
    
    private func masterSign() {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        log("Master sign function disabled", type: .cryptoDetails)
        // Do nothing
    }
    
    private func publishApprovedAndCosignedTxs() {
        log("Teambrella service start \(#function)", type: .cryptoDetails)
        let txs = contentProvider.transactionsApprovedAndCosigned
        log("Teambrella has \(txs.count) approved and cosigned transactions to publish", type: .crypto)
        for tx in txs {
            guard let kind = tx.kind else { continue }

            switch kind {
            case .payout,
                 .withdraw,
                 .moveToNextWallet:
                wallet.publish(tx: tx, completion: { hash in
                    log("Teambrella service published tx hash: \(hash)", type: .crypto)
                    self.contentProvider.transactionSetToPublished(tx: tx, hash: hash)
                }, failure: { error in
                    log("Teambrella service failed to publish tx \(tx.id.uuidString)", type: [.error, .crypto] )
                    log("Error: \(String(describing: error))", type: [.error, .crypto])
                })
            default:
                // TODO: support move & incoming TXs
                break
            }
        }
        
    }
    
    private func myTeamMultisigIfAny(publicKey: String, myTeammateID: Int, multisigs: [Multisig]) -> Multisig? {
        for multisig in multisigs where multisig.teammate?.id == myTeammateID && multisig.creationTx != nil {
            return multisig
        }
        let sameTeamMultisigs = contentProvider.multisigsWithAddress(publicKey: publicKey, teammateID: myTeammateID)
        return sameTeamMultisigs.first
    }
    
    
    private func getBetterGasPriceForContractCreation(oldPrice: Int) -> Int {
        var betterPrice = oldPrice + 1;
        let recommendedPrice = 0 //refreshContractCreateGasPrice()
        if (recommendedPrice > betterPrice) {
            betterPrice = recommendedPrice;
        }
        return betterPrice
    }

    private func registerBackgroundTaskIfNeeded(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        #if MAIN_APP
        registerBackgroundTask(completion: completion)
        #endif
    }

    private func endBackgroundTaskIfNeeded(result: UIBackgroundFetchResult,
                                   completion: @escaping (UIBackgroundFetchResult) -> Void) {
        #if MAIN_APP
        endBackgroundTask(result: result, completion: completion)
        #else
        completion(.failed)
        #endif
    }

    #if MAIN_APP
    private func registerBackgroundTask(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask(result: .failed,completion: completion)
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    private func endBackgroundTask(result: UIBackgroundFetchResult,
                                   completion: @escaping (UIBackgroundFetchResult) -> Void) {
        log("Background task ended. Result: \(result.rawValue)", type: .crypto)
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
        completion(result)
    }
    #endif
    
}
