//
//  LocalStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class LocalStorage: Storage {
    var lastKeyTime: Date?
    
    func requestHome(teamID: Int) -> Future<HomeScreenModel> {
        let promise = Promise<HomeScreenModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .home, body: body, success: { response in
                if case .home(let homeModel) = response {
                    promise.resolve(with: homeModel)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .home got \(response)"))
                }
            })
            request.start()
        }
        return promise
    }
    
    func requestTeamFeed(context: FeedRequestContext) -> Future<[FeedEntity]> {
        let promise = Promise<[FeedEntity]>()
        freshKey { key in
            let body = RequestBody(key: key, payload:["teamid": context.teamID,
                                                      "since": context.since,
                                                      "offset": context.offset,
                                                      "limit": context.limit,
                                                      "commentAvatarSize": 32,
                                                      "search": NSNull()])
            let request = TeambrellaRequest(type: .teamFeed, body: body, success: { response in
                if case .teamFeed(let feed) = response {
                    promise.resolve(with: feed)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .teamFeed, got \(response)"))
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func myProxy(userID: String, add: Bool) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload:["UserId": userID,
                                                      "add": add])
            let request = TeambrellaRequest(type: .myProxy, body: body, success: { response in
                if case .myProxy(let isProxy) = response {
                    promise.resolve(with: isProxy)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .myProxy, got \(response)"))
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func freshKey(completion: @escaping (Key) -> Void) {
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
