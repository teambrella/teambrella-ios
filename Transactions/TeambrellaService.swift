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
    lazy var blockchain: BlockchainService = {  BlockchainService(fetcher: self.fetcher, server: self.server) }()
    weak var delegate: TeambrellaServiceDelegate?
    var fetcher: BlockchainStorageFetcher { return storage.fetcher }
    
    var key: Key { return Key(base58String: self.fetcher.user.privateKey, timestamp: self.server.timestamp) }
    
    init() {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func update() {
        server.initClient(privateKey: fetcher.user.privateKey) { [unowned self] success in
            if success {
                self.storage.autoApproveTransactions()
                self.blockchain.updateData()
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
                          signatures: signatures) { reply in
                            switch reply {
                            case .success(let json, let timestamp):
                                self.storage.update(with: json, updateTime: timestamp) { [weak self] in
                                    if let me = self {
                                        me.delegate?.teambrellaDidUpdate(service: me)
                                    }
                                }
                                break
                            case .failure(let error):
                                 print("server request failed with error: \(error)")
                            }
        }
    }
    
}
