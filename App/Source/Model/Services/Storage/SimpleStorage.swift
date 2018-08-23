//
/* Copyright(C) 2017 Teambrella, Inc.
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

final class SimpleStorage {
    enum StorageKey: String {
        case teamID                      = "teambrella.currentTeam.id"
        case recentScene                 = "storage.recentScene"
        case uniqueIdentifier            = "com.teambrella.application.uniqueIdentifier"
        case swipeHelperWasShown         = "com.teambrella.swipeHelperWasShown"
        case outdatedVersionLastShowDate = "com.teambrella.outdatedVersionLastShowDate"
        case disabledPushLastShowDate    = "com.teambrella.disabledPushLastShowDate"
        case didLogWithKey               = "com.teambrella.didLogWithKey"
        case lastUserType                = "com.teambrella.lastUserType"
        case privateDemoKey              = "com.teambrella.privateDemoKey"
        case userID                      = "com.teambrella.userID"

        case didMoveToRealGroup          = "com.teambrella.didMoveToRealGroup"
    }
    
    func store(int: Int, forKey: StorageKey) {
        store(string: "\(int)", forKey: forKey)
    }
    
    func store(bool: Bool, forKey: StorageKey) {
        UserDefaults.standard.set(bool, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func store(string: String, forKey: StorageKey) {
        UserDefaults.standard.set(string, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }

    func store(date: Date, forKey: StorageKey) {
        UserDefaults.standard.set(date, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }

    func date(forKey: StorageKey) -> Date? {
        return UserDefaults.standard.object(forKey: forKey.rawValue) as? Date
    }
    
    func string(forKey: StorageKey) -> String? {
        return UserDefaults.standard.object(forKey: forKey.rawValue) as? String
    }

    func bool(forKey: StorageKey) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey.rawValue)
    }
    
    func int(forKey: StorageKey) -> Int? {
        return string(forKey: forKey).flatMap { Int($0) }
    }
    
    func cleanValue(forKey: StorageKey) {
        UserDefaults.standard.set(nil, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
}
