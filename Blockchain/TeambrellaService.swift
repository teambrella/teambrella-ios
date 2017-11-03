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

class TeambrellaService {
    struct Constant {
        static let maxAttempts = 3
        static let gasLimit = 1300000
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
    var wallet: EthWallet { return EthWallet(isTestNet: server.isTestnet, processor: processor) }
    
    weak var delegate: TeambrellaServiceDelegate?
    
    var key: Key { return Key(base58String: self.contentProvider.user.privateKey, timestamp: self.server.timestamp) }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startUpdating() {
        sync()
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
    
    func clear() throws {
        try contentProvider.clear()
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
        server.getUpdates(privateKey: user.privateKey,
                          lastUpdated: user.lastUpdated,
                          transactions: txsToUpdate,
                          signatures: signatures) { [unowned self] reply in
                            switch reply {
                            case .success(let json, let timestamp):
                                log("BlockchainStorage Server update to local db received json: \(json)", type: .crypto)
                                let factory = EntityFactory(fetcher: self.contentProvider)
                                factory.updateLocalDb(txs: txsToUpdate, signatures: signatures, json: json)
                                user.lastUpdated = timestamp
                                self.contentProvider.save()
                                completion(true)
                                break
                            case .failure(let error):
                                print("server request failed with error: \(error)")
                                completion(false)
                            }
        }
    }
    
    func autoApproveTransactions() {
        let txs = contentProvider.transactionsResolvable
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
    
    func sync() {
        print("Teambrella service start sync")
        queue.addOperation {
            self.queue.isSuspended = true
            self.createWallets(gasLimit: Constant.gasLimit, completion: { success in
                print("wallet created \(success)")
                self.queue.isSuspended = false
            })
        }
        
        queue.addOperation {
            self.verifyIfWalletIsCreated(gasLimit: Constant.gasLimit)
        }
        
        queue.addOperation {
            self.depositWallet()
        }
        
        queue.addOperation {
            self.autoApproveTxs()
        }
        
        queue.addOperation {
            self.cosignApprovedTransactions()
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
            print("Teambrella service executed all sync operations")
        }
        
    }
    
    func createWallets(gasLimit: Int, completion: @escaping (Bool) -> Void) {
        print("Teambrella service start \(#function)")
        let myPublicKey = key.publicKey
        let multisigsToCreate = contentProvider.multisigsToCreate(publicKey: myPublicKey)
        guard !multisigsToCreate.isEmpty else {
            completion(false)
            return
        }
        
        let wallet = EthWallet(isTestNet: server.isTestnet, processor: processor)
        wallet.checkMyNonce(success: { [weak self] nonce in
            guard let `self` = self else { return }
            var nonce = nonce
            
            let group = DispatchGroup()
            var success = false
            for multisig in multisigsToCreate {
                if let sameMultisig = self.myTeamMultisigIfAny(publicKey: myPublicKey,
                                                               myTeammateID: multisig.teammate?.id ?? 0,
                                                               multisigs: multisigsToCreate) {
                    // todo: move "cosigner list", and send to the server the move tx (not creation tx).
                    ////boolean needServerUpdate = (sameTeammateMultisig.address != null);
                    ////operations.add(mTeambrellaClient.setMutisigAddressTxAndNeedsServerUpdate(m,
                    //                                                      sameTeammateMultisig.address,
                    //                                                      sameTeammateMultisig.creationTx,
                    //                                                      needServerUpdate));
                } else {
                    let gasPrice = wallet.contractGasPrice
                    group.enter()
                    wallet.createOneWallet(myNonce: nonce,
                                           multisig: multisig,
                                           gaslLimit: gasLimit,
                                           gasPrice: gasPrice,
                                           completion: { txHex in
                                            // There could be 2 my pending mutisigs (Current and Next) for the same
                                            // team. So we remember the first creation tx and don't create 2 contracts
                                            // for the same team.
                                            multisig.creationTx = txHex
                                            multisig.needServerUpdate = false
                                            
                                            self.contentProvider.createUnconfirmed(id: multisig.id,
                                                                                   tx: txHex,
                                                                                   gasPrice: gasPrice,
                                                                                   nonce: nonce,
                                                                                   date: Date())
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
    
    func verifyIfWalletIsCreated(gasLimit: Int) -> Bool {
        print("Teambrella service start \(#function)")
        let publicKey = key.publicKey
        let creationTxs = contentProvider.multisigsInCreation(publicKey: publicKey)
        var result = true
        let group = DispatchGroup()
        for multisig in creationTxs {
            group.enter()
            wallet.validateCreationTx(multisig: multisig, gasLimit: gasLimit, success: { [weak self] address in
                multisig.address = address
                multisig.needServerUpdate = true
                self?.contentProvider.save()
                group.leave()
            }, failure: { error in
                result = false
                group.leave()
            })
            group.wait()
        }
        return result
    }
    
    func depositWallet() {
        print("Teambrella service start \(#function)")
        
    }
    
    func autoApproveTxs() {
        print("Teambrella service start \(#function)")
        
    }
    
    func cosignApprovedTransactions() {
        print("Teambrella service start \(#function)")
        
    }
    
    func masterSign() {
        print("Teambrella service start \(#function)")
        
    }
    
    func publishApprovedAndCosignedTxs() {
        print("Teambrella service start \(#function)")
        
    }
    
    // MARK: Private
    
    private func myTeamMultisigIfAny(publicKey: String, myTeammateID: Int, multisigs: [Multisig]) -> Multisig? {
        for multisig in multisigs where multisig.teammate?.id == myTeammateID && multisig.creationTx != nil {
            return multisig
        }
        let sameTeamMultisigs = contentProvider.multisigsWithAddress(publicKey: publicKey, teammateID: myTeammateID)
        return sameTeamMultisigs.first
    }
    
    //    func update() -> Bool {
    //        return false
    //    }
    
}

// Helpers

extension TeambrellaService {
    func approve(tx: Tx) {
        contentProvider.transactionsChangeResolution(txs: [tx], to: .approved)
        self.delegate?.teambrellaDidUpdate(service: self)
        //update()
    }
}
