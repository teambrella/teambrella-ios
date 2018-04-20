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

    var timestamp: Int64 = 0
    var isDemoUser: Bool { return lastUserType == .demo }
    var isUserSelected: Bool { return lastUserType == .real }
    var hasRealPrivateKey: Bool {
        return keychain.value(forKey: .privateKey) != nil
        && SimpleStorage().bool(forKey: .didLogWithKey)
    }

    var privateKey: String {
        return isDemoUser ? demoPrivateKey : realPrivateKey
    }

    private var lastUserType: LastUserType {
        guard let lastUserType = SimpleStorage().string(forKey: .lastUserType) else { return .none }

        return LastUserType(rawValue: lastUserType) ?? .none
    }

    private var realPrivateKey: String {
        storeLastUserType(type: .real)

        guard let privateKey = keychain.value(forKey: .privateKey) else {
            return newPrivateKey()
        }

        return privateKey
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

    private init() { }

    func saveNewPrivateKey(string: String) {
        keychain.save(value: string, forKey: .privateKey)
        log("Key Storage saved new private key: \(string)", type: [.cryptoDetails, .info])
    }
    
    func clearLastUserType() {
        storeLastUserType(type: .none)
    }
    
    func setToRealUser() {
        storeLastUserType(type: .real)
    }

    func setToDemoUser() {
        storeLastUserType(type: .demo)
    }
    
    func deleteStoredKeys() {
        keychain.clear()
        clearLastUserType()
        SimpleStorage().cleanValue(forKey: .privateDemoKey)
    }

    /// creates new private BTC key
    private func newPrivateKey() -> String {
        let newKey = Key(timestamp: timestamp)
        let privateKey = newKey.privateKey
        saveNewPrivateKey(string: privateKey)
        return privateKey
    }

    private func storeLastUserType(type: LastUserType) {
        SimpleStorage().store(string: type.rawValue, forKey: .lastUserType)
    }
    
}
