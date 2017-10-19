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

protocol CurrencyLike {
    var name: String { get }
    var symbol: String { get }
    var code: String { get }
    var child: CurrencyLike? { get }
    var childRate: Double { get }
    var coinCode: String { get }
    var parent: CurrencyLike? { get }
}

protocol CurrencyTransformable {
    func rate(to: CurrencyTransformable) -> Double?
}

extension CurrencyTransformable where Self: CurrencyLike {
    func rate(to: CurrencyTransformable) -> Double? {
        var rate: Double = 1
        guard type(of: to) != type(of: self) else { return rate }
        
        var superCoin = parent
        while let coin = superCoin {
            rate /= coin.childRate
            if let child = coin.child, type(of: child) == type(of: self) {
                return rate
            }
            superCoin = coin.parent
        }
        
        var childCoin = child
        rate = 1
        while let coin = childCoin {
            rate *= coin.childRate
            if let parent = coin.parent, type(of: parent) == type(of: self) {
                return rate
            }
            childCoin = coin.child
        }
        return nil
    }
}

struct Ethereum: CurrencyLike {
    let name = "Ethereum"
    let code = "ETH"
    let symbol = "Ξ"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Finney() }
    let parent: CurrencyLike? = nil
    let childRate: Double = 1000
    
    /*
     let finneyRate = 1000
     let szaboRate = 1000_000
     let gweiRate = 1000_000_000
     let mweiRate = 1000_000_000_000
     let kweiRate = 1000_000_000_000_000
     let weiRate = 1000_000_000_000_000_000
     */
}

struct Finney: CurrencyLike {
    let name = "Finney"
    let code = "mETH"
    let symbol = "mΞ"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Szabo() }
    var parent: CurrencyLike? { return Ethereum() }
    let childRate: Double = 1000
}

struct Szabo: CurrencyLike {
    let name = "Szabo"
    let code = "µETH"
    let symbol = "µΞ"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Gwei() }
    var parent: CurrencyLike? { return Finney() }
    let childRate: Double = 1000
}

struct Gwei: CurrencyLike {
    let name = "Gwei"
    let code = "Gwei"
    let symbol = "Gwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Mwei() }
    var parent: CurrencyLike? { return Szabo() }
    let childRate: Double = 1000
}

struct Mwei: CurrencyLike {
    let name = "Mwei"
    let code = "Mwei"
    let symbol = "Mwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Kwei() }
    var parent: CurrencyLike? { return Gwei() }
    let childRate: Double = 1000
}

struct Kwei: CurrencyLike {
    let name = "Kwei"
    let code = "Kwei"
    let symbol = "Kwei"
    
    var coinCode: String { return child?.code ?? "" }
    var child: CurrencyLike? { return Wei() }
    var parent: CurrencyLike? { return Mwei() }
    let childRate: Double = 1000
}

struct Wei: CurrencyLike {
    let name = "Wei"
    let code = "Wei"
    let symbol = "Wei"
    
    var coinCode: String { return child?.code ?? "" }
    let child: CurrencyLike? = nil
    var parent: CurrencyLike? { return Kwei() }
    let childRate: Double = 1
}
