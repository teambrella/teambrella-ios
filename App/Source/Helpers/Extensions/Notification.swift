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

extension Notification.Name {
    static let teambrellaCoreDataWillClear = Notification.Name("teambrella.coreData.willClear")
    static let cryptoKeyFailure = Notification.Name("teambrella.crypto.key.failure")

    static let internetUnreachable = Notification.Name("teambrella.reachability.noInternet")
    static let internetConnected = Notification.Name("teambrella.reachability.internetIsReachable")
    
    static let serverUnreachable = Notification.Name("teambrella.reachability.serverNotConnected")

    static let dynamicLinkReceived = Notification.Name("teambrella.dynamicLinkReceived")
}
