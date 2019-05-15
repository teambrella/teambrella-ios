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
        case contractAddress = "ContractAddress"
        case cosigners = "Cosigners"
        case coveragePart = "CoveragePart"
        case teamPart = "TeamPart"
        case amountFiatMonth = "AmountFiatMonth"
        case amountFiatYear = "AmountFiatYear"
        case fundWalletComment = "FundWalletComment"
    }
    
    var currencyRate: Double
    var cryptoBalance: Ether
    var cryptoReserved: Ether
    var needCrypto: Ether
    var recommendedCrypto: Ether
    var fundAddress: String
    var defaultWithdrawAddress: String?
    var contractAddress: String?
    var cosigners: [CosignerEntity]
    var coveragePart: CoverageEntity
    var teamPart: TeamPart?
    var amountFiatMonth: Fiat
    var amountFiatYear: Fiat
    var fundWalletComment: String
}
