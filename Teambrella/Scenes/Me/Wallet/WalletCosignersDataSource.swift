//
//  WalletCosignersDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
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
import SwiftyJSON

class WalletCosignersDataSource {
    var items: [CosignerEntity] = []
    var count: Int { return items.count }
    let limit: Int = 100
    var isSilentUpdate = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var offset = 0
    var isLoading = false
    var isEmpty: Bool { return items.isEmpty }
    
    init() {
    }
    
    func loadData(cosigners: [CosignerEntity]) {
        var offset = isSilentUpdate ? 0 : count
        guard !isLoading else { return }
        
        isLoading = true
        if isSilentUpdate {
            items.removeAll()
            isSilentUpdate = false
        }
        for cosigner in cosigners {
            items.append(cosigner)
        }
        offset += items.count
        onUpdate?()
        isLoading = false
    }
    
//    func updateSilently() {
//        isSilentUpdate = true
//        loadData()
//    }
    
    subscript(indexPath: IndexPath) -> CosignerEntity {
        let model = items[indexPath.row]
        return model
    }
}
