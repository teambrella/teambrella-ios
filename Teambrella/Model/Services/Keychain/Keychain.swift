//
//  Keychain.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

enum KeychainKey: String {
    case ethPrivateAddress
    case ethPrivateAddressDemo
    case lastUserType
}

class Keychain {
    @discardableResult
    class func save(value: String, forKey key: KeychainKey) -> Bool {
        return KeychainWrapper.standard.set(value, forKey: key.rawValue)
    }
    
    class func value(forKey key: KeychainKey) -> String? {
        return KeychainWrapper.standard.string(forKey: key.rawValue)
    }
    
    @discardableResult
    class func removeValue(forKey key: KeychainKey) -> Bool {
        return KeychainWrapper.standard.removeObject(forKey: key.rawValue)
    }
    
    class func clear() {
        removeValue(forKey: .ethPrivateAddress)
        removeValue(forKey: .ethPrivateAddressDemo)
        removeValue(forKey: .lastUserType)
    }
    
}
