//
//  AccountService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

/*
 TX processing:
 1. Tx & TxOutputs (w/o change) are obtained from the server
 2. User approves the Tx or N days pass
 3. Client notifies server on approval
 4. TxInputs and a TxOutput for change are obtained from the server
 5. Tx is signed/co-signed
 */
class AccountService {
    struct Constant {
        static let noAutoApproval: Decimal = 1_000_000
    }
    
    let server: BlockchainServer
    let storage: TransactionsStorage
    var connected = false
    
    lazy var key: Key? = {
        return Key(base58String: BlockchainServer.Constant.fakePrivateKey, timestamp: self.server.timestamp)
    }()
    
    init(server: BlockchainServer, storage: TransactionsStorage) {
        self.server = server
        self.storage = storage
    }
    
    func close() {
        dispose()
    }
    
    func dispose() {
        connected = false
        storage.dispose()
    }
    
    func save() {
        storage.save { _ in }
    }
}
