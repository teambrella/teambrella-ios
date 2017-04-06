//
//  AmbrellaRequest.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AmbrellaRequestType: String {
    case timestamp = "me/GetTimestamp"
    case initClient = "me/InitClient"
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case newPost = "post/newPost"
}

enum AmbrellaResponseType {
    case timestamp(Int64)
    case initClient
    case teammatesList([Teammate])
    case teammate(Teammate)
    case newPost(Post)
}

typealias AmbrellaRequestSuccess = (_ result: AmbrellaResponseType) -> Void
typealias AmbrellaRequestFailure = (_ error: Error) -> Void

struct AmbrellaRequest {
    let type: AmbrellaRequestType
    var parameters: [String: String]?
    let success: AmbrellaRequestSuccess
    var failure: AmbrellaRequestFailure?
    var body: RequestBody?
    
    init (type: AmbrellaRequestType,
          parameters: [String: String]? = nil,
          body: RequestBody? = nil,
          success: @escaping AmbrellaRequestSuccess,
          failure: AmbrellaRequestFailure? = nil) {
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
    
    private func parseReply(reply: JSON) {
        switch type {
        case .timestamp:
            success(AmbrellaResponseType.timestamp(reply["Timestamp"].int64Value))
        case .teammatesList:
            if let teammates = TeammateEntityFactory.teammates(from: reply) {
                success(AmbrellaResponseType.teammatesList(teammates))
            } else {
                failure?(AmbrellaErrorFactory.unknownError())
            }
        case .teammate:
            if let teammate = TeammateEntityFactory.teammate(from: reply) {
                success(AmbrellaResponseType.teammate(teammate))
            } else {
                failure?(AmbrellaErrorFactory.unknownError())
            }
        case .newPost:
            if let post = PostEntityFactory.post(with: reply) {
                success(AmbrellaResponseType.newPost(post))
            }
        default:
            break
        }
    }
    
}
