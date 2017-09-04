//
//  WalletTransactionsDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class WalletTransactionsDataSource {
    var items: [WalletTransactionsCellModel] = []
    var count: Int { return items.count }
    let teamID: Int
    let limit: Int = 100
    var search: String = ""
    var isLoading: Bool = false
    var hasMore: Bool = true
    var canLoad: Bool { return hasMore && !isLoading }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    subscript(indexPath: IndexPath) -> WalletTransactionsCellModel {
        let model = items[indexPath.row]
        return model
    }
    
    func loadData() {
        guard canLoad else { return }
        
        isLoading = true
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            guard let teamId = self?.teamID, let offset = self?.count,
                let limit = self?.limit, let search = self?.search else { return }
            
            let body = RequestBody(key: key, payload:["TeamId": teamId,
                                                      "offset": offset,
                                                      "limit": limit,
                                                      "search": search])
            let request = TeambrellaRequest(type: .walletTransactions, body: body, success: { [weak self] response in
                if case .walletTransactions(let transactions) = response {
                    self?.hasMore = (transactions.count == limit)
                    self?.items += transactions
                    self?.isLoading = false
                    self?.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.isLoading = false
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
}
