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

struct WalletEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case currencyRate = "CurrencyRate"
        case cryptoBalance = "CryptoBalance"
        case cryptoReserved = "CryptoReserved"
        case needCrypto = "NeedCrypto"
        case recommendedCrypto = "RecommendedCrypto"
        case fundAddress = "FundAddress"
        case defaultWithdrawAddress = "DefaultWithdrawAddress"
        case cosigners = "Cosigners"
        case coveragePart = "CoveragePart"
        case teamPart = "TeamPart"
    }
    
    var currencyRate: Double
    var cryptoBalance: Double
    var cryptoReserved: Double
    var needCrypto: Double
    var recommendedCrypto: Double
    var fundAddress: String
    var defaultWithdrawAddress: String?
    var cosigners: [CosignerEntity]
    var coveragePart: CoverageEntity
    var teamPart: TeamPartConcrete?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        currencyRate = try container.decode(Double.self, forKey: .currencyRate)
        cryptoBalance = try container.decode(Double.self, forKey: .cryptoBalance)
        cryptoReserved = try container.decode(Double.self, forKey: .cryptoReserved)
        needCrypto = try container.decode(Double.self, forKey: .needCrypto)
        recommendedCrypto = try container.decode(Double.self, forKey: .recommendedCrypto)
        fundAddress = try container.decode(String.self, forKey: .fundAddress)
        defaultWithdrawAddress = try container.decodeIfPresent(String.self, forKey: .defaultWithdrawAddress)
        cosigners = try container.decode([CosignerEntity].self, forKey: .cosigners)
        coveragePart = try container.decode(CoverageEntity.self, forKey: .coveragePart)
        teamPart = try container.decodeIfPresent(TeamPartConcrete.self, forKey: .teamPart)
    }
    
    init() {
        currencyRate = 0
        cryptoBalance = 0
        cryptoReserved = 0
        needCrypto = 0
        recommendedCrypto = 0
        fundAddress = ""
        defaultWithdrawAddress = ""
        cosigners = []
        coveragePart = CoverageEntity()
        teamPart = TeamPartConcrete()
    }

}
