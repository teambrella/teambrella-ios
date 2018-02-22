//
//  Keychain.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.
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
import KeychainAccess

#if SURILLA
    enum OldKeychainKey: String {
        case ethPrivateAddress
    }
#else
    enum OldKeychainKey: String {
        case ethPrivateAddress = "ethPrivateAddress"
    }
#endif

enum KeychainKey: String {
    case privateKey = "Private Key"
}

class KeychainService {
    let keychain = Keychain(service: Constant.keychainName)
        .accessibility(.always)
        .synchronizable(true)

    // support for older stored keys
    let oldKeychain = Keychain().accessibility(.always)

    @discardableResult
    func save(value: String, forKey key: KeychainKey) -> Bool {
        do {
            try keychain
                .synchronizable(true)
                .set(value, key: key.rawValue)
            return true
        } catch {
            print("keychain error: \(error)")
            return false
        }
    }
    
    func value(forKey key: KeychainKey) -> String? {
        do {
            var value = try keychain.getString(key.rawValue)
            
            // try to use previous locally saved value if any
            if value == nil {
                let oldKey = KeychainKeyAdaptor().oldKey(from: key)
                value = try oldKeychain.getString(oldKey.rawValue)
                let saved = value.map { self.save(value: $0, forKey: key) }
                log("KeychainService storing newValue from OldValue: \(String(describing: value)), saved: \(saved)",
                    type: [.crypto, .info])
            }
            return value
        } catch {
            print("error getting string from keychain: \(error)")
            return nil
        }
    }
    
    @discardableResult
    func removeValue(forKey key: KeychainKey) -> Bool {
        do {
            try keychain.remove(key.rawValue)
            return true
        } catch let error {
            print("error removing item from keychain: \(error)")
            return false
        }
    }
    
    func clear() {
        removeValue(forKey: .privateKey)
    }

    struct Constant {
        #if SURILLA
        static let keychainName = "Surilla iOS App"
        #else
        static let keychainName: String = "Teambrella iOS App"
        #endif
    }

}

struct KeychainKeyAdaptor {
    func oldKey(from key: KeychainKey) -> OldKeychainKey {
        switch key {
        default:
            return .ethPrivateAddress
        }
    }
}
