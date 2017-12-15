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
    
    var cryptoBalance: Double = 0.0
    var cryptoReserved: Double = 0.0
    
    var maxMETHAvailable: Double { return (cryptoBalance - cryptoReserved) * 1000 }
    
    var ethereumAddress: EthereumAddress? {
        didSet {
            guard let address = ethereumAddress?.string else { return }
            
            detailsModel.toValue = address
        }
    }
    
    lazy var detailsModel = {
        return self.modelBuilder.detailsModel(maxAmount: maxMETHAvailable)
    }()
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    private var lastChunk: WithdrawChunk? {
        didSet {
            if let chunk = lastChunk {
                transactions[0].removeAll()
                transactions[1].removeAll()
                transactions[2].removeAll()
                
                cryptoBalance = chunk.cryptoBalance.double
                cryptoReserved = chunk.cryptoReserved.double
                
                for tx in chunk.txs {
                    let state = tx.serverTxState
                    if state.isQueued {
                        addQueued(transaction: tx)
                    } else if state.isProcessing {
                        addProcessing(transaction: tx)
                    } else if state.isHistory {
                        addHistory(transaction: tx)
                    }
                }
            }
        }
    }
    
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
        case 0:
            return ""
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
    
    func currencyName(section: Int) -> String? {
        let string = "mETH"
        switch section {
        case 0:
            return ""
        case 1:
            return transactions[0].isEmpty ? nil : string
        case 2:
            return transactions[1].isEmpty ? nil : string
        case 3:
            return transactions[2].isEmpty ? nil : string
        default:
            return nil
        }
    }
    
    func loadData() {
        isLoading = true
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
    }
    
    func withdraw() {
        guard let amount = Double(detailsModel.amountValue),
            let address = EthereumAddress(string: detailsModel.toValue) else { return }
        
        isLoading = true
        service.dao.withdraw(teamID: teamID, amount: amount / 1000, address: address).observe { [weak self] result in
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
        
        if indexPath.section == 0 { return detailsModel }
        let transaction = transactions[indexPath.section - 1][indexPath.row]
        return modelBuilder.modelFrom(transaction: transaction)
    }
}
