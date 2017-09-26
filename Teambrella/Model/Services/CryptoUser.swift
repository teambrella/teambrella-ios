//
//  CryptoUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

final class CryptoUser {
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
