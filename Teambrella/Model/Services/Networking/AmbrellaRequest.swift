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
}

enum AmbrellaResponseType {
    case timestamp(Int64)
}

typealias AmbrellaRequestSuccess = (_ result: AmbrellaResponseType) -> Void
typealias AmbrellaRequestFailure = (_ error: Error) -> Void
struct AmbrellaRequest {
    let type: AmbrellaRequestType
    var parameters: [String: String]?
    let success: AmbrellaRequestSuccess
    var failure: AmbrellaRequestFailure?
    
    init (type: AmbrellaRequestType,
          parameters: [String: String]? = nil,
          success: @escaping AmbrellaRequestSuccess,
          failure: AmbrellaRequestFailure? = nil) {
        self.type = type
        self.parameters = parameters
        self.success = success
        self.failure = failure
    }
    
    func start() {
        ServerService.askServer(for: type.rawValue, parameters: parameters, success: { json in
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
        }
    }
    
}
