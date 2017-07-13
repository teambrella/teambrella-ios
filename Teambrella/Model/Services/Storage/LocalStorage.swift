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
    
    mutating func requestTeamFeed(teamID: Int,
                                  since: UInt64 = 0,
                                  offset: Int = 0,
                                  limit: Int = 100,
                                  success: @escaping() -> Void,
                                  failure: @escaping ErrorHandler) {
        freshKey { key in
            let body = RequestBody(key: key, payload:["teamid": teamID,
                                                      "since": since,
                                                      "offset": offset,
                                                      "limit": limit,
                                                      "commentAvatarSize": 32,
                                                      "search": NSNull()])
            let request = TeambrellaRequest(type: .teamFeed, body: body, success: { response in
                /*
                if case .claim(let claim) = response {
                    self?.setupClaim(claim: claim)
                    self?.onUpdate?()
                    print("Loaded enhanced claim \(claim)")
                }
 */
                }, failure: { error in
                    failure(error)
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
