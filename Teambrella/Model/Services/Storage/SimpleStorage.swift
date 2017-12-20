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

class SimpleStorage {
    enum StorageKey: String {
        case teamID = "teambrella.currentTeam.id"
        case recentScene = "storage.recentScene"
        case uniqueIdentifier = "com.teambrella.application.uniqueIdentifier"
    }
    
    func store(int: Int, forKey: StorageKey) {
        store(string: "\(int)", forKey: forKey)
    }
    
    func store(string: String, forKey: StorageKey) {
        UserDefaults.standard.set(string, forKey: forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func string(forKey: StorageKey) -> String? {
        return UserDefaults.standard.object(forKey: forKey.rawValue) as? String
    }
    
    func int(forKey: StorageKey) -> Int? {
        return string(forKey: forKey).flatMap { Int($0) }
    }
    
    func cleanValue(forKey: StorageKey) {
        UserDefaults.standard.setNilValueForKey(forKey.rawValue)
        UserDefaults.standard.synchronize()
    }
}
