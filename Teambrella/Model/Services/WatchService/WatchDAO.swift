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

class WatchDAO {
    let cache: WatchDAOCache = WatchDAOCache(deprecateInterval: 60 * 3)
    let dao: DAO = service.dao
    var isCaching: Bool = true

    func getWallet(completion: @escaping (WatchWallet?) -> Void) {
        if isCaching, let wallet = cache.wallet, cache.isValid(item: wallet) {
            completion(wallet.value)
        } else {
            guard let session = service.session, let team = session.currentTeam else {
                completion(nil)
                return
            }

            dao.requestWallet(teamID: team.teamID).observe { [weak self] result in
                guard let `self` = self else { return }

                switch result {
                case let .value(wallet):

                    let watchWallet = self.cache.saveWallet(wallet, team: team)
                    completion(watchWallet)
                default:
                    completion(nil)
                }
            }
        }

    }

    func getCoverage(completion: @escaping (WatchCoverage?) -> Void) {
        if isCaching, let item = cache.coverage, cache.isValid(item: item) {
            completion(item.value)
        } else {
            guard let session = service.session, let team = session.currentTeam else {
                completion(nil)
                return
            }

            dao.requestCoverage(for: Date(), teamID: team.teamID).observe { [weak self] result in
                guard let `self` = self else { return }

                switch result {
                case let .value(coverage):
                    let watchCoverage = self.cache.saveCoverage(coverage)
                    completion(watchCoverage)
                default:
                    completion(nil)
                }
            }
        }

    }
}
