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
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var wallet: WalletEntity?
    
    init() {
      //items = fakeModels()
    }
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = service.server.key
            let body = RequestBody(key: key, payload: ["TeamId": service.session.currentTeam?.teamID ?? 0])
            let request = TeambrellaRequest(type: .wallet, body: body, success: { [weak self] response in
                if case .wallet(let wallet) = response {
                    self?.wallet = wallet
                    self?.createCellModels(with: wallet)
                    self?.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func createCellModels(with wallet: WalletEntity) {
        items.append(WalletHeaderCellModel(amount: wallet.cryptoBalance,
                                           reserved: wallet.cryptoReserved,
                                           available: wallet.cryptoBalance - wallet.cryptoReserved))
        items.append(WalletFundingCellModel(maxCoverageFunding: wallet.coveragePart.nextCoverage,
                                            uninterruptedCoverageFunding: wallet.coveragePart.coverage))
        let avatars = wallet.cosigners.map { $0.avatar }
        items.append(WalletButtonsCellModel(avatars: avatars))
    }
    
    subscript(indexPath: IndexPath) -> WalletCellModel {
        return items[indexPath.row]
    }
}

extension WalletDataSource {
    func fakeModels() -> [WalletCellModel] {
        return [WalletHeaderCellModel.fake, WalletFundingCellModel.fake, WalletButtonsCellModel.fake]
    }
}
