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
    let storage = BlockchainStorage()
    lazy var service: BlockchainService = {  BlockchainService(fetcher: self.fetcher, server: self.server) }()
    weak var delegate: TeambrellaServiceDelegate?
    var fetcher: BlockchainStorageFetcher { return storage.fetcher }
    
    init() {
        server.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update() {
        server.initClient(privateKey: fetcher.user.privateKey) { [unowned self] success in
            if success {
                self.storage.autoApproveTransactions()
                self.service.updateData()
                self.save()
            }
        }
        
        
    }
    
    func save() {
        let lastUpdated = storage.lastUpdated
        guard let transactions = fetcher.transactionsNeedServerUpdate else { fatalError() }
        guard let signatures = fetcher.signaturesToUpdate else { fatalError() }
        
        server.getUpdates(privateKey: User.Constant.tmpPrivateKey,
                          lastUpdated: lastUpdated,
                          transactions: transactions,
                          signatures: signatures)
    }
    
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
