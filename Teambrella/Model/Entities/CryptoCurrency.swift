//
//  CurrencyTransformable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.08.17.
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

/*
protocol CurrencyLike {
    var name: String { get }
    var symbol: String { get }
    var code: String { get }
    var child: CurrencyLike? { get }
    var childRate: Decimal { get }
    var coinCode: String { get }
    var parent: CurrencyLike? { get }
}
*/

/*
protocol CurrencyTransformable {
    func rate(to: CurrencyTransformable) -> Decimal?
}

extension CurrencyTransformable where Self: CurrencyLike {
    func rate(to: CurrencyTransformable) -> Decimal? {
        var rate: Decimal = 1
        guard type(of: to) != type(of: self) else { return rate }
        
        var superCoin = parent
        while let coin = superCoin {
            rate /= coin.childRate
            if type(of: coin) == type(of: to) {
                return rate
            }
            superCoin = coin.parent
        }
        
        var childCoin = child
        rate = childRate
        while let coin = childCoin {
            if type(of: coin) == type(of: to) {
                return rate
            }
            rate *= coin.childRate
            childCoin = coin.child
        }
        return nil
    }
}
*/

/*
 let finneyRate = 1000
 let szaboRate = 1000_000
 let gweiRate = 1000_000_000
 let mweiRate = 1000_000_000_000
 let kweiRate = 1000_000_000_000_000
 let weiRate = 1000_000_000_000_000_000
 */

struct Ethereum {
    let name = "Ethereum"
    let code = "ETH"
    let symbol = "Ξ"

    //var coinCode: String { return child?.code ?? "" }
    let childRate: Decimal = 1000
}

struct Finney {
    let name = "Finney"
    let code = "mETH"
    let symbol = "mΞ"

   // var coinCode: String { return child?.code ?? "" }
    let childRate: Decimal = 1000
}

/*
struct Szabo: CurrencyLike, CurrencyTransformable {
    let name = "Szabo"
    let code = "µETH"
    let symbol = "µΞ"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Gwei() }
    var parent: CurrencyLike? { return Finney() }
    let childRate: Decimal = 1000
}

struct Gwei: CurrencyLike, CurrencyTransformable {
    let name = "Gwei"
    let code = "Gwei"
    let symbol = "Gwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Mwei() }
    var parent: CurrencyLike? { return Szabo() }
    let childRate: Decimal = 1000
}

struct Mwei: CurrencyLike, CurrencyTransformable {
    let name = "Mwei"
    let code = "Mwei"
    let symbol = "Mwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Kwei() }
    var parent: CurrencyLike? { return Gwei() }
    let childRate: Decimal = 1000
}

struct Kwei: CurrencyLike, CurrencyTransformable {
    let name = "Kwei"
    let code = "Kwei"
    let symbol = "Kwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Wei() }
    var parent: CurrencyLike? { return Mwei() }
    let childRate: Decimal = 1000
}

struct Wei: CurrencyLike, CurrencyTransformable {
    let name = "Wei"
    let code = "Wei"
    let symbol = "Wei"
    
    var coinCode: String { return child?.code ?? "" }
    let child: CurrencyLike? = nil
    var parent: CurrencyLike? { return Kwei() }
    let childRate: Decimal = 1
}
*/
