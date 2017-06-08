//
//  TeambrellaRequest.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TeambrellaRequestType: String {
    case timestamp = "me/GetTimestamp"
    case initClient = "me/InitClient"
    case updates = "me/GetUpdates"
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case newPost = "post/newPost"
    case registerKey = "me/registerKey"
    case claimsList = "claim/getList"
    case claim = "claim/getOne"
    case setVote = "claim/setVote"
    case claimUpdates = "claim/getUpdates"
}

enum TeambrellaResponseType {
    case timestamp
    case initClient
    case updates
    case teammatesList([TeammateLike])
    case teammate(ExtendedTeammate)
    case newPost(Post)
    case registerKey
    case claimsList([ClaimLike])
    case claim(EnhancedClaimEntity)
    case setVote(JSON)
    case claimUpdates(JSON)
}

typealias TeambrellaRequestSuccess = (_ result: TeambrellaResponseType) -> Void
typealias TeambrellaRequestFailure = (_ error: Error) -> Void

struct TeambrellaRequest {
    let type: TeambrellaRequestType
    var parameters: [String: String]?
    let success: TeambrellaRequestSuccess
    var failure: TeambrellaRequestFailure?
    var body: RequestBody?
    
    init (type: TeambrellaRequestType,
          parameters: [String: String]? = nil,
          body: RequestBody? = nil,
          success: @escaping TeambrellaRequestSuccess,
          failure: TeambrellaRequestFailure? = nil) {
        self.type = type
        self.parameters = parameters
        self.success = success
        self.failure = failure
        self.body = body
    }
    
    func start() {
        service.server.ask(for: type.rawValue, parameters: parameters, body: body, success: { json in
            self.parseReply(reply: json)
        }, failure: { error in
            print(error)
            self.failure?(error)
        })
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func parseReply(reply: JSON) {
        switch type {
        case .timestamp:
            success(.timestamp)
        case .teammatesList:
            if let teammates = TeammateEntityFactory.teammates(from: reply) {
                success(.teammatesList(teammates))
            } else {
                failure?(TeambrellaErrorFactory.unknownError())
            }
        case .teammate:
            if let teammate = TeammateEntityFactory.extendedTeammate(from: reply) {
                success(.teammate(teammate))
            } else {
                failure?(TeambrellaErrorFactory.unknownError())
            }
        case .newPost:
            if let post = PostFactory.post(with: reply) {
                success(.newPost(post))
            }
        case .registerKey:
            success(.registerKey)
        case .claimsList:
            let claims = ClaimFactory.claims(with: reply)
            success(.claimsList(claims))
        case .claim:
            success(.claim(EnhancedClaimEntity(json: reply)))
        case .setVote:
            success(.setVote(reply))
        case .claimUpdates:
            success(.claimUpdates(reply))
        case .updates:
            break
        default:
            break
        }
    }
    
}
