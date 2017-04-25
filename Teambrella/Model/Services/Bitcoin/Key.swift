//
//  Key.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct Key {
    private let key: BTCKey
    let isTestnet: Bool
    var timestamp: Int64
    var privateKey: String {
        return (key.privateKey as Data).base58String
    }
    var publicKey: String {
        return (key.publicKey as Data).hexString
    }
    var address: String {
        return key.privateKeyAddress.string
    }
    var signature: String {
        guard let data = key.signature(forMessage: String(timestamp)) else {
            fatalError("Couldn't create signature data")
        }
        
        return data.base64EncodedString()
    }
    
    init(base58String: String, timestamp: Int64) {
        self.timestamp = timestamp
        if base58String.characters.count == 52,
            (base58String.hasPrefix("K") || base58String.hasPrefix("L")) {
            let address = BTCPrivateKeyAddress(string: base58String)
            key = BTCKey(privateKeyAddress: address)
            isTestnet = false
        } else {
            let address = BTCPrivateKeyAddressTestnet(string: base58String)
            key = BTCKey(privateKeyAddress: address)
            isTestnet = true
        }
    }
    
    init() {
        key = BTCKey()
        timestamp = 0
        isTestnet = true
    }
    
}
