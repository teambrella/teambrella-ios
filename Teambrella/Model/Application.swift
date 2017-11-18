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

class Application {
    struct Constant {
        static let uniqueIdentifier = "com.teambrella.application.uniqueIdentifier"
    }
    var version: String { return Bundle.main
        .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "" }
    
    var build: String { return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "" }
    /// version in format: "ios-0.2.3.64"
    var clientVersion: String { return "ios-\(version).\(build)" }
    
    var uniqueIdentifier: String {
        if let stored = UserDefaults.standard.object(forKey: Constant.uniqueIdentifier) as? String {
            return stored
        } else {
            let id = UUID()
            UserDefaults.standard.set(id.uuidString, forKey: Constant.uniqueIdentifier)
            UserDefaults.standard.synchronize()
            return id.uuidString
        }
    }
}
