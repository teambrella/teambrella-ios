//
//  ErrorPresenter.swift
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
import SwiftMessages

final class ErrorPresenter {
    var ids: [String] = []
    
    func present(error: Error?) {
        guard let error = error else { return }
        
        if let error = error as? TeambrellaError {
            // restart demo if current has expired
            switch error.kind {
            case .brokenSignature:
                if let session = service.session, session.isDemo {
                    service.router.manageBrokenSignature()
                } else {
                    service.router.logout()
                }
            case .unsupportedClientVersion:
                let router = service.router
                SODManager(router: router).showCriticallyOldVersion()
            default:
                presentTeambrella(error: error)
            }
        } else {
            let error = error as NSError
            switch error.code {
            case NSURLErrorTimedOut,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorNotConnectedToInternet:
                presentServerUnreacheable()
            default:
                presentGeneral(error: error)
            }
        }
    }

    func hideAll() {
        for id in ids {
            SwiftMessages.hide(id: id)
        }
        ids.removeAll()
    }

    func hide(id: String) {
        SwiftMessages.hide(id: id)
        if let idx = ids.index(of: id) {
            ids.remove(at: idx)
        }
    }

    private func presentGeneral(error: Error) {
        showMessage(title: "Error.oops".localized, details: "\(error)")
    }

    private func presentTeambrella(error: TeambrellaError) {
        showMessage(title: "Error.oops".localized, details: error.description)
    }

    private func presentServerUnreacheable() {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.warning)
        view.configureDropShadow()

        view.configureContent(title: "", body: "Main.Notification.noServer".localized)

        var config = SwiftMessages.defaultConfig
        service.router.navigator.map { config.presentationContext = .view($0.view) }
        config.duration = .seconds(seconds: 5)
        SwiftMessages.hideAll()
        SwiftMessages.show(config: config, view: view)
        NotificationCenter.default.post(name: .serverUnreachable, object: nil)
    }

    private func showMessage(title: String, details: String) {
        guard let navigator = service.router.navigator else { return }

        let message = MessageView.viewFromNib(layout: .cardView)
//        message.configureTheme(.info)
        message.configureTheme(backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5), foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        message.configureDropShadow()
        message.iconLabel = nil
        let id = message.id
        message.configureContent(title: title,
                                 body: nil,
                                 iconImage: nil,
                                 iconText: nil,
                                 buttonImage: nil,
                                 buttonTitle: "Error.DetailsButton.title".localized) { [weak self] button in
                                    let vc = UIAlertController(title: title,
                                                               message: details,
                                                               preferredStyle: .alert)
                                    let cancel = UIAlertAction(title: "General.ok".localized,
                                                               style: .cancel,
                                                               handler: nil)
                                    vc.addAction(cancel)
                                    service.router.frontmostViewController?.present(vc,
                                                                                    animated: true,
                                                                                    completion: nil)
                                    self?.hide(id: id)
        }

        var config = SwiftMessages.defaultConfig
        config.presentationContext = .view(navigator.view)
        config.duration = .seconds(seconds: 5)
        config.presentationStyle = .bottom
        SwiftMessages.show(config: config, view: message)
        ids.append(id)
    }

}
