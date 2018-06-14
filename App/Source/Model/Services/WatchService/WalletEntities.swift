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

protocol DictionaryConvertible {
    var dict: [String: Any] { get }

    init?(dict: [String: Any])
}

enum WatchCommand: Int, DictionaryConvertible {
    case wallet
    case coverage

    var dict: [String: Any] { return ["cmd": self.rawValue] }

    init?(dict: [String: Any]) {
        guard let rawValue = dict["cmd"] as? Int else { return nil }

        self.init(rawValue: rawValue)
    }
}

struct WatchWallet: DictionaryConvertible {
    let mETH: Double
    let rate: Double
    let team: WatchTeam

    var dict: [String: Any] {
        return ["mETH": mETH,
                "rate": rate,
                "team": team.dict
        ]
    }

    init?(dict: [String: Any]) {
        guard let mETH = dict["mETH"] as? Double,
            let rate = dict["rate"] as? Double,
            let teamDict = dict["team"] as? [String: Any],
            let team = WatchTeam(dict: teamDict) else { return nil }

        self.mETH = mETH
        self.rate = rate
        self.team = team
    }

    init(mETH: Double, rate: Double, team: WatchTeam) {
        self.mETH = mETH
        self.rate = rate
        self.team = team
    }

}

struct WatchTeam: DictionaryConvertible {
    let name: String
    let logo: String
    let currency: String

    var dict: [String: Any] {
        return ["name": name,
                "logo": logo,
                "currency": currency
        ]
    }

    init?(dict: [String: Any]) {
        guard let name = dict["name"] as? String,
            let logo = dict["logo"] as? String,
            let currency = dict["currency"] as? String else { return nil }

        self.name = name
        self.logo = logo
        self.currency = currency
    }

    init(name: String, logo: String, currency: String) {
        self.name = name
        self.logo = logo
        self.currency = currency
    }

}

struct WatchCoverage: DictionaryConvertible {
    let coverage: Int

    var dict: [String: Any] {
        return ["coverage": coverage]
    }

    init?(dict: [String: Any]) {
        guard let coverage = dict["coverage"] as? Int else { return nil }

        self.coverage = coverage
    }

    init(coverage: Int) {
        self.coverage = coverage
    }
}
