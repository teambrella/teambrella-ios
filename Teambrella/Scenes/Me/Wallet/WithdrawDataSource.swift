//
/* Copyright(C) 2017 Teambrella, Inc.
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

final class WithdrawDataSource {
    let teamID: Int
    private(set) var isLoading = false
    private(set) var sections: Int = 1

    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?

    private var lastChunk: WithdrawChunk?
    private let modelBuilder = WithdrawModelBuilder()
    private var transactions: [[WithdrawTx]] = []
    
    init(teamID: Int) {
        self.teamID = teamID
        for _ in 0..<3 {
            transactions.append([WithdrawTx]())
        }
    }
    
    func rows(in section: Int) -> Int {
        guard section > 0 else { return 1 }
        guard section - 1 < transactions.count else { return 0 }
        
        return transactions[section - 1].count
    }
    
    func headerName(section: Int) -> String? {
        switch section {
        case 1:
            return transactions[0].isEmpty ? nil : "Me.Wallet.Withdraw.header.queued".localized
        case 2:
            return transactions[1].isEmpty ? nil : "Me.Wallet.Withdraw.header.inProgress".localized
        case 3:
            return transactions[2].isEmpty ? nil : "Me.Wallet.Withdraw.header.history".localized
        default:
            return nil
        }
    }
    
    func loadData() {
        isLoading = true
        fakeLoad()
        /*
         service.dao.requestWithdrawTransactions(teamID: teamID).observe { [weak self] result in
         switch result {
         case let .value(chunk):
         self?.lastChunk = chunk
         self?.onUpdate?()
         case let .error(error):
         self?.onError?(error)
         default:
         break
         }
         self?.isLoading = false
         }
         */
    }
    
    // MARK: Private
    
    private func addQueued(transaction: WithdrawTx) {
        if transactions[0].isEmpty { sections += 1 }
        transactions[0].append(transaction)
    }
    
    private func addProcessing(transaction: WithdrawTx) {
        if transactions[1].isEmpty { sections += 1 }
        transactions[1].append(transaction)
    }
    
    private func addHistory(transaction: WithdrawTx) {
        if transactions[2].isEmpty { sections += 1 }
        transactions[2].append(transaction)
    }
    
    // MARK: Subscripts
    
    subscript(indexPath: IndexPath) -> WithdrawCellModel? {
        guard indexPath.section < sections else { return nil }
        guard indexPath.row < rows(in: indexPath.section) else { return nil }
        
        if indexPath.section == 0 { return modelBuilder.detailsModel() }
        let transaction = transactions[indexPath.section - 1][indexPath.row]
        return modelBuilder.modelFrom(transaction: transaction)
    }
    
}

private extension WithdrawDataSource {
    private func fakeLoad() {
        for _ in 0..<5 {
            guard let fake = WithdrawTx.fake(state: 0) else { return }
            
            addQueued(transaction: fake)
        }
        for _ in 0..<5 {
            guard let fake = WithdrawTx.fake(state: 10) else { return }
            
            addQueued(transaction: fake)
        }
        for _ in 0..<5 {
            guard let fake = WithdrawTx.fake(state: 20) else { return }
            
            addQueued(transaction: fake)
        }
        self.onUpdate?()
        isLoading = false
    }
}
