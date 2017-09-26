//
//  Key.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.03.17.

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

struct Key {
    let key: BTCKey
    var isTestnet: Bool
    var timestamp: Int64
    var privateKey: String {
        return key.wif //(key.privateKey as Data).base58String
    }
    var publicKey: String {
        return (key.compressedPublicKey as Data).hexString
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
        key = BTCKey(wif: base58String)
        isTestnet = false
        /*
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
 */
    }
    
    init(timestamp: Int64) {
        key = BTCKey()
        self.timestamp = timestamp
        isTestnet = false
    }
    
}
