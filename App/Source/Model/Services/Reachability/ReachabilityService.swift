//
//  ReachabilityService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.09.2017.
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
import Reachability
import SwiftMessages

final class ReachabilityService {
    //swiftlint:disable:next force_unwrapping
    let reachability = try! Reachability()
    var notification: MessageView?
    
    init() {
        try? reachability.startNotifier()
        reachability.whenReachable = { [weak self] reachability in
            self?.notifyReachable()
            self?.hideUnreachable()
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.notyfyUnreachable()
            self?.showUnreachable(with: reachability)
        }
    }

    func notyfyUnreachable() {
        NotificationCenter.default.post(name: .internetUnreachable, object: nil)
    }

    func notifyReachable() {
        NotificationCenter.default.post(name: .internetConnected, object: nil)
    }

    func showUnreachable(with: Reachability? = nil) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.warning)
        view.configureDropShadow()
        notification = view
        
        view.configureContent(title: "", body: "Main.Notification.noInternet".localized)
        
        var config = SwiftMessages.defaultConfig
        service.router.navigator.map { config.presentationContext = .view($0.view) }
        config.duration = .forever
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
    }
    
    func hideUnreachable() {
        notification = nil
        SwiftMessages.hideAll()
        service.error.retry()
    }
}
