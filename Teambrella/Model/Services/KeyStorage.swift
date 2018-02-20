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
    
    static let shared = KeyStorage()
    let keychain = KeychainService()
    
    private init() { }
    
    var lastUserType: LastUserType {
        guard let lastUserType = SimpleStorage().string(forKey: .lastUserType) else { return .none }
        
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
        keychain.clear()
        let storage = SimpleStorage()
        storage.cleanValue(forKey: .lastUserType)
        storage.cleanValue(forKey: .privateDemoKey)
    }
    
   private var realPrivateKey: String {
       storeLastUserType(type: .real)
//    return "cUNX4HYHK3thsjDKEcB26qRYriw8uJLtt8UvDrM98GbUBn22HMrY"
        return privateKey(for: .ethPrivateAddress)
    }
    
    private var demoPrivateKey: String {
        let storage = SimpleStorage()
        storeLastUserType(type: .demo)
        guard let key = storage.string(forKey: .privateDemoKey) else {
            let newKey = Key(timestamp: timestamp)
            let privateKey = newKey.privateKey
            storage.store(string: privateKey, forKey: .privateDemoKey)
            return privateKey
        }

        return key
    }
    
    private func privateKey(for key: KeychainKey) -> String {
        guard let privateKey = keychain.value(forKey: key) else {
            return createPrivateKey(for: key)
        }
        
        return privateKey
    }
    
    private func createPrivateKey(for key: KeychainKey) -> String {
        let newKey = Key(timestamp: timestamp)
        let privateKey = newKey.privateKey
        keychain.save(value: privateKey, forKey: key)
        return self.privateKey
    }
    
    private func storeLastUserType(type: LastUserType) {
        SimpleStorage().store(string: type.rawValue, forKey: .lastUserType)
    }
    
}
