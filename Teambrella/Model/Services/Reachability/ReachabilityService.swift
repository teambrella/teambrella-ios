//
//  ReachabilityService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Reachability
import SwiftMessages

final class ReachabilityService {
    //swiftlint:disable:next force_unwrapping
    let reachability = Reachability()!
    var notification: MessageView?
    
    init() {
        try? reachability.startNotifier()
        reachability.whenReachable = { [weak self] reachability in
            self?.hideUnreachable()
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.showUnreachable(with: reachability)
        }
    }
    
    func showUnreachable(with: Reachability) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.warning)
        view.configureDropShadow()
        notification = view
        
        view.configureContent(title: "", body: "Main.Notification.noInternet".localized)
        
        var config = SwiftMessages.defaultConfig
        service.router.navigator.map { config.presentationContext = .view($0.view) }
        config.duration = .forever
        SwiftMessages.show(config: config, view: view)
    }
    
    func hideUnreachable() {
        guard let id = notification?.id else { return }
        
        notification = nil
        SwiftMessages.hide(id: id)
    }
}
