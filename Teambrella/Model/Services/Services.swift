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
import PKHUD

fileprivate(set)var service = ServicesHandler.i

class ServicesHandler {
    static let i = ServicesHandler()
    
    /// routing between application scenes
    let router = MainRouter()
    
    /// internet connection monitoring
    let reachability: ReachabilityService = ReachabilityService()
    
    /// server interoperability
    lazy var server = ServerService()
    
    /// data access object
    lazy var dao: DAO = ServerDAO()
    
    /// push notifications handling service
    lazy var push: PushService = PushService()
    
    /// errors handling service
    lazy var error: ErrorPresenter = ErrorPresenter()
    
    /// logging service
    lazy var log: Log = Log(logLevel: .crypto)
    
    /// service to store private keys and last user logged in
    lazy var keyStorage: KeyStorage = KeyStorage()
    
    // WIP!
    // old analogue of cryptoWorker. Should be merged and deleted
    lazy var teambrella = TeambrellaService()
    
    /// service to work with current Crypto currency and it's blockchain
//    lazy var cryptoWorker: CryptoWorker = EthereumWorker()
    
    /// socket messaging service
    var socket: SocketService?
    
    /// service to store current user state. Teams, names unread counts etc
    var session: Session?
    
    // MARK: Utilities
    
    /// gives the symbol of currency used in the current team (e.g. $)
    var currencySymbol: String { return session?.currentTeam?.currencySymbol ?? "" }
    
    /// gives the name code of the currency used in the current team (e.g. USD)
    var currencyName: String { return session?.currentTeam?.currency ?? "" }
    
    private init() {
        PKHUD.sharedHUD.gracePeriod = 0.5
    }
    
}
