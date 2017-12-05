//
//  WalletDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

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

class WalletDataSource {
    var items: [WalletCellModel] = []
    var count: Int { return items.count }
    var fundAddress: String = ""
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var wallet: WalletEntity?
    
    init() {
    }
    
    func loadData() {
        guard !isLoading else { return }
        guard let teamID = service.session?.currentTeam?.teamID else { return }
        
        isLoading = true
        service.dao.requestWallet(teamID: teamID).observe { [weak self] result in
            switch result {
            case let .value(wallet):
                self?.wallet = wallet
                self?.createCellModels(with: wallet)
                self?.fundAddress = wallet.fundAddress
                self?.onUpdate?()
            case let .error(error):
                 self?.onError?(error)
            default:
                break
            }
            self?.isLoading = false
        }
    }
    
    func emptyWallet() {
       let wallet = WalletEntity.empty()
        self.wallet = wallet
        createCellModels(with: wallet)
       fundAddress = wallet.fundAddress
        onUpdate?()
    }
    
    func createCellModels(with wallet: WalletEntity) {
        items.append(WalletHeaderCellModel(amount: wallet.cryptoBalance,
                                           reserved: wallet.cryptoReserved,
                                           available: wallet.cryptoBalance - wallet.cryptoReserved,
                                           currencyRate: wallet.currencyRate))
        items.append(WalletFundingCellModel(maxCoverageFunding: wallet.coveragePart.nextCoverage,
                                            uninterruptedCoverageFunding: wallet.coveragePart.coverage))
        let avatars = wallet.cosigners.map { $0.avatar }
        var avatarsPreview: [String] = []
        if avatars.count >= 3 {
       avatarsPreview = Array(avatars[..<3])
        }
        items.append(WalletButtonsCellModel(avatars: avatars, avatarsPreview: avatarsPreview))
    }
    
    subscript(indexPath: IndexPath) -> WalletCellModel {
        return items[indexPath.row]
    }
}
