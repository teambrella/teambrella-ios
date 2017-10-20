//
//  CryptoUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.09.2017.
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

final class KeyStorage {
    enum LastUserType: String {
        case none, real, demo
    }
    
    var lastUserType: LastUserType {
        guard let lastUserType = Keychain.value(forKey: .lastUserType) else { return .none }
        
        return LastUserType(rawValue: lastUserType) ?? .none
    }
    
    var timestamp: Int64 = 0
    var isDemoUser: Bool { return lastUserType != .real }
    
    var privateKey: String {
        return isDemoUser ? demoPrivateKey : realPrivateKey
    }
    
    func clearLastUserType() {
        storeLastUserType(type: .none)
    }
    
    func setToRealUser() {
        storeLastUserType(type: .real)
    }
    
    func deleteStoredKeys() {
        Keychain.clear()
    }
    
   private var realPrivateKey: String {
       storeLastUserType(type: .real)
        return privateKey(for: .ethPrivateAddress)
    }
    
    private var demoPrivateKey: String {
        storeLastUserType(type: .demo)
        return privateKey(for: .ethPrivateAddressDemo)
    }
    
    private func privateKey(for key: KeychainKey) -> String {
        guard let privateKey = Keychain.value(forKey: key) else {
            return createPrivateKey(for: key)
        }
        
        return privateKey
    }
    
    private func createPrivateKey(for key: KeychainKey) -> String {
        let newKey = Key(timestamp: timestamp)
        let privateKey = newKey.privateKey
        log("New private key type \(key): \(privateKey)", type: .serviceInfo)
        Keychain.save(value: privateKey, forKey: key)
        return privateKey
    }
    
    private func storeLastUserType(type: LastUserType) {
        Keychain.save(value: type.rawValue, forKey: .lastUserType)
    }
    
}
