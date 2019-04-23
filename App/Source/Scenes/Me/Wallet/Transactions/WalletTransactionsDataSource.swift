//
//  WalletTransactionsDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
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
//

import Foundation

class WalletTransactionsDataSource {
    var items: [[WalletTransactionsCellModel]] = []
    var sections: Int { return items.count }
    let teamID: Int
    let limit: Int = 100
    var search: String = ""
    var isLoading: Bool = false
    var hasMore: Bool = true
    var canLoad: Bool { return hasMore && !isLoading }
    var isEmpty: Bool { return items.isEmpty }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    subscript(indexPath: IndexPath) -> WalletTransactionsCellModel {
        let section = items[indexPath.section]
        return section[indexPath.row]
    }
    
    func itemsIn(section: Int) -> Int {
        guard section < items.count else {
            return 0
        }
        return items[section].count
    }
    
    func loadData() {
        guard canLoad else { return }
        
        isLoading = true
        
        let totalCount = items.reduce(0) {$0 + $1.count}
        service.dao.requestWalletTransactions(teamID: teamID, offset: totalCount, limit: limit, search: search)
            .observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .value(transactions):
                    self.hasMore = transactions.count == self.limit
                    let cellModels = TransactionsCellModelBuilder().cellModels(from: transactions)
                    for model in cellModels {
                        if self.items.count == 0 || self.items.count > 0 && self.items.last?.first?.month != model.month {
                            self.items.append([])
                        }
                        self.items[self.items.count-1].append(model)
                    }
                    
                    self.onUpdate?()
                case let .error(error):
                    self.onError?(error)
                }
                self.isLoading = false
        }
    }
    
}
