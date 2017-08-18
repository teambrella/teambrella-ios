//
//  CryptoCurrency.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol CryptoCurrency {
    var name: String { get }
    var code: String { get }
    var coinCode: String { get }
    var symbol: String { get }
    var coin: CryptoCurrency? { get }
    var coinRate: Int { get }
}

struct Ethereum: CryptoCurrency {
    let name = "Ethereum"
    let code = "ETH"
    let symbol = "Ξ"
    
    var coinCode: String { return coin?.code ?? "" }
    var coin: CryptoCurrency? { return Finney() }
    let coinRate = 1000
    
    let finneyRate = 1000
    let szaboRate = 1000_000
    let gweiRate = 1000_000_000
    let mweiRate = 1000_000_000_000
    let kweiRate = 1000_000_000_000_000
    let weiRate = 1000_000_000_000_000_000
}

struct Finney: CryptoCurrency {
    let name = "Finney"
    let code = "mETH"
    let symbol = "mΞ"
    
    var coinCode: String { return coin?.code ?? "" }
    var coin: CryptoCurrency? { return Szabo() }
    let coinRate = 1000
}

struct Szabo: CryptoCurrency {
    let name = "Szabo"
    let code = "µETH"
    let symbol = "µΞ"
    
    var coinCode: String { return coin?.code ?? "" }
     var coin: CryptoCurrency? { return Gwei() }
    let coinRate = 1000
}

struct Gwei: CryptoCurrency {
    let name = "Gwei"
    let code = "Gwei"
    let symbol = "Gwei"
    
    var coinCode: String { return coin?.code ?? "" }
    var coin: CryptoCurrency? { return Mwei() }
    let coinRate = 1000
}

struct Mwei: CryptoCurrency {
    let name = "Mwei"
    let code = "Mwei"
    let symbol = "Mwei"
    
    var coinCode: String { return coin?.code ?? "" }
    var coin: CryptoCurrency? { return Kwei() }
    let coinRate = 1000
}

struct Kwei: CryptoCurrency {
    let name = "Kwei"
    let code = "Kwei"
    let symbol = "Kwei"
    
    var coinCode: String { return coin?.code ?? "" }
    var coin: CryptoCurrency? { return Wei() }
    let coinRate = 1000
}

struct Wei: CryptoCurrency {
    let name = "Wei"
    let code = "Wei"
    let symbol = "Wei"
    
    var coinCode: String { return coin?.code ?? "" }
    let coin: CryptoCurrency? = nil
    let coinRate = 1
}
