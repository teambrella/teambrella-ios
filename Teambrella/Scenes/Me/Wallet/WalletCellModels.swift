//
//  WalletCellModels.swift
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

protocol WalletCellModel {
    
}

struct WalletHeaderCellModel: WalletCellModel {
    let amount: Double
    let reserved: Double
    let available: Double
    let currencyRate: Double
    
    static var fake: WalletCellModel { return WalletHeaderCellModel(amount: 0, reserved: 0, available: 0, currencyRate: 0) }
}

struct WalletFundingCellModel: WalletCellModel {
    let maxCoverageFunding: Double
    let uninterruptedCoverageFunding: Double
    
    static var fake: WalletCellModel {
        return WalletFundingCellModel(maxCoverageFunding: 0, uninterruptedCoverageFunding: 0)
    }
}

struct WalletButtonsCellModel: WalletCellModel {
    let avatars: [String]
    
    static var fake: WalletCellModel { return WalletButtonsCellModel(avatars: []) }
}
