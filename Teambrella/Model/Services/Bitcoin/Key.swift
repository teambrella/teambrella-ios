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
    let timestamp: Int64
    
    var privateKey: String {
        return (key.privateKey as Data).base58String
    }
    var publicKey: String {
        return (key.publicKey as Data).hexString//base58String
    }
    var address: String {
        return key.privateKeyAddress.string
    }
    
    var signature: String {
        guard let data = key.signature(forMessage: String(timestamp)) else {
            fatalError("Couldn't create signature data")
        }
        guard let hash = BTCHash256(data) else { fatalError("Couldn't create hash256") }
        
        return hash.base64EncodedString()
    }
    
    init?(base58String: String, timestamp: Int64) {
        guard base58String.characters.count == 52,
            (base58String.hasPrefix("K") || base58String.hasPrefix("L")) else { return nil }
        
        self.timestamp = timestamp
        let address = BTCPrivateKeyAddress(string: base58String)
        key = BTCKey(privateKeyAddress: address)
    }
    
}
