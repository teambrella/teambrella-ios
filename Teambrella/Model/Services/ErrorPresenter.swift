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
            if  error.kind == .brokenSignature {
                if let session = service.session, session.isDemo {
                    service.router.manageBrokenSignature()
                } else {
                    service.router.logout()
                }
            } else {
                presentTeambrella(error: error)
            }
        } else {
            presentGeneral(error: error)
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
        showMessage(title: "Error", details: "\(error)")
    }
    
    private func presentTeambrella(error: TeambrellaError) {
        showMessage(title: "\(error.kind)", details: error.description)
    }
    
    private func showMessage(title: String, details: String) {
        let message = MessageView.viewFromNib(layout: .cardView)
        message.configureTheme(.warning)
        message.configureDropShadow()
        message.configureContent(title: title, body: details)
        message.iconLabel = nil
        let id = message.id
        message.configureContent(title: title,
                                 body: details,
                                 iconImage: nil,
                                 iconText: nil,
                                 buttonImage: nil,
                                 buttonTitle: "OK") { [weak self] button in
                                    self?.hide(id: id)
        }
        
        var config = SwiftMessages.defaultConfig
        service.router.navigator.map { config.presentationContext = .view($0.view) }
        config.duration = .forever
        config.presentationStyle = .bottom
        SwiftMessages.show(config: config, view: message)
        ids.append(id)
    }
    
}
