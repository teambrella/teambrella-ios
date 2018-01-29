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
import SwiftyJSON

protocol TeambrellaServiceDelegate: class {
    func teambrellaDidUpdate(service: TeambrellaService)
}

class TeambrellaService: NSObject {
    struct Constant {
        static let maxAttempts = 3
        static let gasLimit = 1300001
    }
    
    let dispatchQueue = DispatchQueue(label: "com.teambrella.teambrellaService.queue", qos: .background)
    
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.teambrella.teambrellaService.operationQueue"
        // make this queue serial
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = dispatchQueue
        return queue
    }()
    
    var hasNews: Bool = false
    
    let server = BlockchainServer()
    let contentProvider: TeambrellaContentProvider = TeambrellaContentProvider()
    
    lazy var processor: EthereumProcessor = { EthereumProcessor.standard }()
    lazy var wallet: EthWallet = { EthWallet(isTestNet: server.isTestnet, processor: processor) }()
    
    weak var delegate: TeambrellaServiceDelegate?
    
    var key: Key { return Key(base58String: self.contentProvider.user.privateKey, timestamp: self.server.timestamp) }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startUpdating(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        sync(completion: completion)
    }
    
    private func update(completion: @escaping (Bool) -> Void) {
        log("Teambrella service begins updates", type: .crypto)
        // let blockchain = BlockchainService(contentProvider: contentProvider, server: server)
        updateData { success in
            if success {
                //  blockchain.updateData()
                self.contentProvider.save()
                self.delegate?.teambrellaDidUpdate(service: self)
            }
            completion(success)
        }
        
    }
    
    var isStorageCleared = false {
        didSet {
            if isStorageCleared {
                queue.cancelAllOperations()
            }
        }
    }
    func clear() throws {
        try contentProvider.clear()
        isStorageCleared = true
    }
    
    func updateData(completion: @escaping (Bool) -> Void) {
        server.initClient(privateKey: contentProvider.user.privateKey) { [unowned self] success in
            if success {
                self.autoApproveTransactions()
                self.serverUpdateToLocalDb { success in
                    if success {
                        
                        //                        self.updateAddresses()
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func serverUpdateToLocalDb(completion: @escaping (Bool) -> Void) {
        let txsToUpdate = contentProvider.transactionsNeedServerUpdate
        let signatures = contentProvider.signaturesToUpdate
        let user = contentProvider.user
        let multisigsToUpdate = contentProvider.multisigsNeedsServerUpdate

        server.getUpdates(privateKey: user.privateKey,
                          lastUpdated: user.lastUpdated,
                          multisigs: multisigsToUpdate,
                          transactions: txsToUpdate,
                          signatures: signatures
        ) { [unowned self] reply in
            guard !self.isStorageCleared else {
                completion(false)
                return
            }

            switch reply {
            case .success(let json, let timestamp):
                log("BlockchainStorage Server update to local db received json: \(json)", type: .cryptoRequests)
                let factory = EntityFactory(fetcher: self.contentProvider)
                factory.updateLocalDb(txs: txsToUpdate, signatures: signatures, multisigs: multisigsToUpdate, json: json)
                user.lastUpdated = timestamp
                self.contentProvider.save()
                completion(true)
                break
            case .failure(let error):
                log("server request failed with error: \(error)", type: [.error, .crypto])
                completion(false)
            }
        }
    }
    
    func autoApproveTransactions() {
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
    
    /*
     private func updateAddresses() {
     for teammate in contentProvider.teammates {
     guard teammate.addresses.isEmpty == false else { continue }
     
     if teammate.addressCurrent == nil {
     let filtered = teammate.addresses.filter { $0.status == UserAddressStatus.current }
     if let curServerAddress = filtered.first {
     curServerAddress.status = .current
     }
     }
     }
     }
     */
    
    //    private var observerToken: NSKeyValueObservation?
    
    //    init() {
    //        observerToken = service.server.observe(\.timestamp) { [weak self] object, change in
    //            self?.processor.key = object.key
    //        }
    //    }
    
    func sync(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        log("Teambrella service start sync", type: .crypto)
        log("Public Key: \(key.publicKey)", type: .cryptoDetails)
        isStorageCleared = false
        registerBackgroundTask(completion: completion)
        queue.addOperation {
            self.queue.isSuspended = true
            self.createWallets(gasLimit: Constant.gasLimit, completion: { success in
                log("wallet created \(success)", type: .crypto)
                self.queue.isSuspended = false
            })
        }
        
        queue.addOperation {
            self.queue.isSuspended = true
            self.verifyIfWalletIsCreated(gasLimit: Constant.gasLimit) { success in
                log("wallet creation verified: \(success)", type: .crypto)
                self.queue.isSuspended = false
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
            self.endBackgroundTask(result: .newData,completion: completion)
        }
        
    }
    
    func createWallets(gasLimit: Int, completion: @escaping (Bool) -> Void) {
        log("Teambrella service start \(#function)", type: .crypto)
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
                                                    // There could be 2 my pending mutisigs (Current and Next) for the same
                                                    // team. So we remember the first creation tx and don't create 2 contracts
                                                    // for the same team.
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
    
    func verifyIfWalletIsCreated(gasLimit: Int, completion: (Bool) -> Void) {
        log("Teambrella service start \(#function)", type: .crypto)
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
    
    func recreateWalletIfTimedOut(multisig: Multisig, gasLimit: Int, completion: @escaping (Bool) -> Void) {
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
                                        let newUnconfirmed = self.contentProvider.createUnconfirmed(multisigId: multisig.id,
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
    
    func depositWallet() {
        log("Teambrella service start \(#function)", type: .crypto)
        let publicKey = key.publicKey
        let myCurrentMultisigs = contentProvider.currentMultisigsWithAddress(publicKey: publicKey)
        if let multisig = myCurrentMultisigs.first {
            wallet.deposit(multisig: multisig) { success in
                log("Wallet deposit result: \(success)", type: .crypto)
            }
        }
        
    }
    
    func autoApproveTxs() {
        /*
         Android version:

         List<ContentProviderOperation> operations = new LinkedList<>();
         List<Tx> txs = getTxToApprove();
         for (Tx tx : txs) {
         operations.add(ContentProviderOperation.newUpdate(TeambrellaRepository.Tx.CONTENT_URI)
         .withValue(TeambrellaRepository.Tx.RESOLUTION, TeambrellaModel.TX_CLIENT_RESOLUTION_APPROVED)
         .withValue(TeambrellaRepository.Tx.CLIENT_RESOLUTION_TIME, mSDF.format(new Date()))
         .withValue(TeambrellaRepository.Tx.NEED_UPDATE_SERVER, true)
         .withSelection(TeambrellaRepository.Tx.ID + "=?", new String[]{tx.id.toString()})
         .build());
         }
         return operations;
         */
        log("Teambrella service start \(#function)", type: .crypto)
        let txs = contentProvider.transactionsToApprove
        log("Teambrella service has \(txs.count) transactions to approve", type: .crypto)
        contentProvider.transactionsChangeResolution(txs: txs, to: .approved, when: Date())
    }
    
    func cosignApprovedTransactions() throws {
        log("Teambrella service start \(#function)", type: .crypto)
        //let publicKey = key.publicKey
        let list = contentProvider.transactionsCosignable
        log("Teambrella service has \(list.count) cosignable transactions", type: .crypto)
        let user = contentProvider.user
        for tx in list {
            try cosignTransaction(transaction: tx, userID: user.id)
        }
        contentProvider.save()
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
        default:
            // TODO: support move & incoming TXs
            break
        }
    }
    
    func masterSign() {
        log("Teambrella service start \(#function)", type: .crypto)
        log("Master sign function disabled", type: .cryptoDetails)
        // Do nothing
    }
    
    func publishApprovedAndCosignedTxs() {
        /*
         Android version:

         ArrayList<ContentProviderOperation> operations = new ArrayList<>();
         List<Tx> txs = mTeambrellaClient.getApprovedAndCosignedTxs(mKey.getPublicKeyAsHex());
         for (Tx tx : txs) {
         Log.d(LOG_TAG, " ---- SYNC -- publishApprovedAndCosignedTxs() detected tx to publish. id:" + tx.id);

         switch (tx.kind) {
         case TeambrellaModel.TX_KIND_PAYOUT:
         case TeambrellaModel.TX_KIND_WITHDRAW:
         case TeambrellaModel.TX_KIND_MOVE_TO_NEXT_WALLET:
         String cryptoTxHash = mWallet.publish(tx);
         Log.d(LOG_TAG, " ---- SYNC -- publishApprovedAndCosignedTxs() published. tx hash:" + cryptoTxHash);
         if (cryptoTxHash != null) {
         operations.add(TeambrellaContentProviderClient.setTxPublished(tx, cryptoTxHash));
         mClient.applyBatch(operations);
         }
         break;
         default:
         // TODO: support move & incoming TXs
         break;
         }
         }

         return !operations.isEmpty();
         */
        log("Teambrella service start \(#function)", type: .crypto)
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
    
    // MARK: Private
    
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
    
    
    //    func update() -> Bool {
    //        return false
    //    }
    
    func registerBackgroundTask(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask(result: .failed,completion: completion)
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask(result: UIBackgroundFetchResult, completion: @escaping (UIBackgroundFetchResult) -> Void) {
        log("Background task ended. Result: \(result.rawValue)", type: .crypto)
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
        completion(result)
    }

    func signToSockets(service: SocketService) {
        log("Teambrella service signing to socket", type: .cryptoDetails)
        service.add(listener: self) { action in
            switch action.command {
            case .dbDump:
                let dumper = Dumper(api: self.server)
                dumper.sendDatabaseDump(privateKey: self.key.privateKey)
            default:
                break
            }
        }
    }
    
}

// Helpers

extension TeambrellaService {
    func approve(tx: Tx) {
        contentProvider.transactionsChangeResolution(txs: [tx], to: .approved)
        self.delegate?.teambrellaDidUpdate(service: self)
        //update()
    }
}
