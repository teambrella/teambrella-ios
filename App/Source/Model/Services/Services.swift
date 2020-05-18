//
//  Services.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.04.17.

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

import Foundation

fileprivate(set)var service = ServicesHandler.shared

final class ServicesHandler {
    static let shared = ServicesHandler()
    
    /// routing between application scenes
    let router = MainRouter()
    
    /// internet connection monitoring
    let reachability: ReachabilityService = ReachabilityService()

    /// information about available services
    let info: InfoMaker = InfoMaker()
    
    /// data access object
    lazy var dao: DAO = {
        let server = ServerService(router: self.router, infoMaker: info)
        let dao = ServerDAO(server: server)
        return dao
    }()

    /// communication with watch
    var watch: WatchService?
    
    /// push notifications handling service
    lazy var push: PushService = PushService()
    
    /// errors handling service
    lazy var error: ErrorPresenter = ErrorPresenter()
    
    /// service to store private keys and last user logged in
    var keyStorage: KeyStorage { return KeyStorage.shared }

    lazy var teambrella = TeambrellaService()
    
    /// socket messaging service
    var socket: SocketService?
    
    /// service to store current user state. Teams, names unread counts etc
    var session: Session?

    //var sinch: SinchService = SinchService()

    // For dynamic links support
    var invite: String?
    var joinTeamID: Int?

    func clearDynamicLinkData() {
        invite = nil
        joinTeamID = nil
    }
}
