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
import SwiftKeychainWrapper

#if TEAMBRELLA
    enum KeychainKey: String {
        case ethPrivateAddress = "teambrella.ethPrivateAddress"
        case ethPrivateAddressDemo = "teambrella.ethPrivateAddress.demo"
        case lastUserType = "teambrella.lastUserType"
    }
#else
    enum KeychainKey: String {
        case ethPrivateAddress = "ethPrivateAddress"
        case ethPrivateAddressDemo = "ethPrivateAddress.demo"
        case lastUserType = "lastUserType"
    }
#endif

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
