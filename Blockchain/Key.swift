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

struct Key: CustomDebugStringConvertible {
    let key: BTCKey
    var isTestnet: Bool
    var timestamp: Int64
    var privateKey: String {
        return isTestnet ? key.wifTestnet : key.wif //(key.privateKey as Data).base58String
    }
    
    var privateKeyData: Data {
        return key.privateKey as Data
    }
    
    var publicKey: String {
        return BTCHexFromData(key.publicKey as Data)
    }

    /*
    var mnemonic: [String] {
        let entropy = key.privateKey as Data
        let mnemonic = BTCMnemonic(entropy: entropy, password: nil, wordListType: .english)
        let words = mnemonic?.words as? [String]
        return words ?? []
    }
    */
    
    var address: String {
        return isTestnet ? key.privateKeyAddressTestnet.string : key.privateKeyAddress.string 
    }
    
    var signature: String {
        guard let data = key.signature(forMessage: String(timestamp)) else {
            fatalError("Couldn't create signature data")
        }
        
        return data.base64EncodedString()
    }
    
    var debugDescription: String {
        return """
        Teambrella.Key:
        private key: \(privateKey)
        private key testnet: \(key.wifTestnet ?? "?")
        address: \(address)
        public key: \(publicKey)
        signatire: \(signature)
        compressed: \(key.isPublicKeyCompressed)
        isTestnet" \(isTestnet)
        """
    }

//    init?(words: [String], timestamp: Int64) {
//        let mnemonic = BTCMnemonic(words: words, password: nil, wordListType: .english)
//        guard let data = mnemonic?.data else { return nil }
//        guard let key = BTCKey(privateKey: data) else { return nil }
//
//        key.isPublicKeyCompressed = true
//        self.key = key
//        self.timestamp = timestamp
//        isTestnet = false
//    }
    
    init(base58String: String, timestamp: Int64) {
        self.timestamp = timestamp
        //key = BTCKey(wif: base58String)
        if (base58String.hasPrefix("K") || base58String.hasPrefix("L") || base58String.hasPrefix("5")) {
            let address = BTCPrivateKeyAddress(string: base58String)
            key = BTCKey(privateKeyAddress: address)
            isTestnet = false
        } else {
            let address = BTCPrivateKeyAddressTestnet(string: base58String)
            key = BTCKey(privateKeyAddress: address)
            isTestnet = true
        }
         key.isPublicKeyCompressed = true
    }
    
    init(timestamp: Int64) {
        key = BTCKey()
        key.isPublicKeyCompressed = true
        self.timestamp = timestamp
        isTestnet = false
    }
    
}
