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
    
    // WIP!
    // old analogue of cryptoWorker. Should be merged and deleted
    lazy var teambrella = TeambrellaService()
    
    /// socket messaging service
    var socket: SocketService?
    
    /// service to store current user state. Teams, names unread counts etc
    var session: Session? {
        didSet {
            self.watch = WatchService()
        }
    }
    
    // MARK: Utilities
    
    /// gives the symbol of currency used in the current team (e.g. $)
    var currencySymbol: String { return session?.currentTeam?.currencySymbol ?? "" }
    
    /// gives the name code of the currency used in the current team (e.g. USD)
    var currencyName: String { return session?.currentTeam?.currency ?? "" }
    
    var myUserID: String { return session?.currentUserID ?? "" }
    
    private init() {
        PKHUD.sharedHUD.gracePeriod = 0.5
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cryptoMalfunction),
                                               name: .cryptoKeyFailure, object: nil)
    }

    @objc
    func cryptoMalfunction() {
        keyStorage.deleteStoredKeys()
        if let vc = service.router.frontmostViewController {
            let message =  """
            Private key that was stored is not a valid BTC key. It will be deleted from the app. Please restart.
            """
            let alert = UIAlertController(title: "Fatal Error", message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(cancel)
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
}
