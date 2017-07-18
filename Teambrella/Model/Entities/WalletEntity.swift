//
//  WalletEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WalletEntity {
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
        coveragePart = CoverageEntity(json: json["CoveragePart"])
        cosigners = json["Cosigners"].arrayValue.flatMap { CosignerEntity(json: $0) }
    }
    
    var currency: String { return json["Currency"].stringValue }
    var currencyRate: Double { return json["CurrencyRate"].doubleValue }
    var btcBalance: Double { return json["BtcBalance"].doubleValue }
    var btcReserved: Double { return json["BtcReserved"].doubleValue }
    var needBtc: Double { return json["NeedBtc"].doubleValue }
    var recommendedBtc: Double { return json["RecommendedBtc"].doubleValue }
    var fundAddress: String { return json["FundAddress"].stringValue }
    var defaultWithdrawAddress: String? { return json["DefaultWithdrawAddress"].string }
    var cosigners: [CosignerEntity]
    var coveragePart: CoverageEntity
    
    static func wallet(with json: JSON) -> WalletEntity {
        return WalletEntity(json: json)
    }
}
