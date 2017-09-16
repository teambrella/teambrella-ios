//
//  WalletCosignersDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
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
