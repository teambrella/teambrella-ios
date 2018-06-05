//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

class WatchDAOCache {
    let deprecateInterval: TimeInterval

    var wallet: WatchCashItem<WatchWallet>?
    var coverage: WatchCashItem<WatchCoverage>?

    init(deprecateInterval: TimeInterval) {
        self.deprecateInterval = deprecateInterval
    }

    func isValid(item: Obsolescent?) -> Bool {
        guard let item = item else { return false }

        let now = Date().timeIntervalSince1970
        return now - item.lastUpdated < deprecateInterval
    }

    func saveWallet(_ wallet: WalletEntity, team: TeamEntity) -> WatchWallet {
        let watchTeam = WatchTeam(name: team.teamName, logo: team.teamLogo, currency: team.currency)
        let watchWallet = WatchWallet(mETH: MEth(wallet.cryptoBalance).value, rate: wallet.currencyRate, team: watchTeam)
        self.wallet = WatchCashItem<WatchWallet>(value: watchWallet)
        return watchWallet
    }

    func saveCoverage(_ coverage: CoverageForDate) -> WatchCoverage {
        let watchCoverage = WatchCoverage(coverage: coverage.coverage.integerPercentage)
        self.coverage = WatchCashItem(value: watchCoverage)
        return watchCoverage
    }
}

protocol Obsolescent {
    var lastUpdated: TimeInterval { get }
}

class WatchCashItem<T>: Obsolescent {
    var lastUpdated: TimeInterval
    var value: T

    var secondsOld: TimeInterval {
        return Date().timeIntervalSince1970 - lastUpdated
    }

    init(value: T) {
        self.value = value
        lastUpdated = Date().timeIntervalSince1970
    }
}
