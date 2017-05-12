//
//  TeambrellaService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol TeambrellaServiceDelegate: class {
    func teambrellaDidUpdate(service: TeambrellaService)
}

class TeambrellaService {
    let server = BlockchainServer()
    let storage = TransactionsStorage()
    weak var delegate: TeambrellaServiceDelegate?
    lazy var fetcher: BlockchainStorageFetcher = {
        return BlockchainStorageFetcher(context: self.storage.context)
    }()
    
    init() {
        server.delegate = self
    }
    
    func update() {
        let lastUpdated = storage.lastUpdated
        guard let transactions = fetcher.resolvableTransactions else { fatalError() }
        guard let signatures = fetcher.signaturesToUpdate else { fatalError() }
        
        server.getUpdates(privateKey: BlockchainServer.Constant.fakePrivateKey,
                          lastUpdated: lastUpdated,
                          transactions: transactions,
                          signatures: signatures)
    }
    // add periodical sync with server
    // add changes listener
    
}

extension TeambrellaService: BlockchainServerDelegate {
    func serverInitialized(server: BlockchainServer) {
        print("server initialized")
    }
    
    func server(server: BlockchainServer, didReceiveUpdates updates: JSON, updateTime: Int64) {
        print("server received updates: \(updates)")
        storage.update(with: updates, updateTime: updateTime) { [weak self] in
            if let me = self {
                me.delegate?.teambrellaDidUpdate(service: me)
            }
        }
    }
    
    func server(server: BlockchainServer, didUpdateTimestamp timestamp: Int64) {
        print("server updated timestamp: \(timestamp)")
    }
    
    func server(server: BlockchainServer, failedWithError error: Error?) {
        error.map { print("server request failed with error: \($0)") }
    }
}
