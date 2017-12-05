//
//  WalletEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.

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
import SwiftyJSON

struct WalletEntity {
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
        coveragePart = CoverageEntity(json: json["CoveragePart"])
        cosigners = json["Cosigners"].arrayValue.flatMap { CosignerEntity(json: $0) }
    }
    
    var currencyRate: Double { return json["CurrencyRate"].doubleValue }
    var cryptoBalance: Double { return json["CryptoBalance"].doubleValue }
    var cryptoReserved: Double { return json["CryptoReserved"].doubleValue }
    var needCrypto: Double { return json["NeedCrypto"].doubleValue }
    var recommendedCrypto: Double { return json["RecommendedCrypto"].doubleValue }
    var fundAddress: String { return json["FundAddress"].stringValue }
    var defaultWithdrawAddress: String? { return json["DefaultWithdrawAddress"].string }
    var cosigners: [CosignerEntity]
    var coveragePart: CoverageEntity
    var teamPart: JSON { return json["TeamPart"] }
    var currency: String { return teamPart["Currency"].stringValue }
    var coverageType: Int { return teamPart["CoverageType"].intValue }
    var teamAccessLevel: TeamAccessLevel {
        return TeamAccessLevel(rawValue: teamPart["TeamAccessLevel"].intValue) ?? .noAccess
    }
    
    static func wallet(with json: JSON) -> WalletEntity {
        return WalletEntity(json: json)
    }
    
    static func empty() -> WalletEntity  {
        /*
         "Txs" : null,
         "DefaultWithdrawAddress" : "0x336a9288ee464752ae94349da78964ad716b1e20",
         "CryptoReserved" : 0,
         "NeedCrypto" : 0.58180862083255402,
         "CurrencyRate" : 8214.667713167657,
         "RecommendedCrypto" : 1.170885834665087,
         "CryptoBalance" : 0.0072685929999789633,
         "Currency" : "ARS",
         "FundAddress" : null,
         "CoveragePart" : {
         "NextCoverage" : 0,
         "ClaimLimit" : 18000,
         "DeductibleAmount" : 0,
         "Coverage" : 0,
         "DaysToNextCoverage" : 0
         }
 */
        let json = JSON(["Cosigners": []])
        return WalletEntity(json: json)
    }

}
