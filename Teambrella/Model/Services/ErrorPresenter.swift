//
//  ErrorPresenter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftMessages

final class ErrorPresenter {
    var ids: [String] = []
    
    func present(error: Error?) {
        guard let error = error else { return }
        
        if let error = error as? TeambrellaError {
            presentTeambrella(error: error)
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
