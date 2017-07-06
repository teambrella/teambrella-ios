//
//  LocalStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct LocalStorage: Storage {
    var lastKeyTime: Date?
    /// request data for home screen
    mutating func requestHome(teamID: Int,
                              success: @escaping (HomeScreenModel) -> Void,
                              failure: @escaping (Error?) -> Void) {
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .home, body: body, success: { response in
                if case .home(let homeModel) = response {
                  success(homeModel)
                } else {
                    failure(nil)
                }
            })
            request.start()
        }
    }
    
    mutating func freshKey(completion: @escaping (Key) -> Void) {
        if let time = lastKeyTime, Date().timeIntervalSince(time) < 60 * 10 {
            completion(service.server.key)
        } else {
            service.server.updateTimestamp(completion: { _, _ in
                defer { self.lastKeyTime = Date() }
                completion(service.server.key)
            })
        }
    }
}
