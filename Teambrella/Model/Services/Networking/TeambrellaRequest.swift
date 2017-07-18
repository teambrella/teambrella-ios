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
    case teams = "me/getTeams"
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case teammateVote = "teammate/setVote"
    case newPost = "post/newPost"
    case registerKey = "me/registerKey"
    case claimsList = "claim/getList"
    case claim = "claim/getOne"
    case claimVote = "claim/setVote"
    case claimUpdates = "claim/getUpdates"
    case claimChat = "claim/getChat"
    case home = "feed/getHome"
    case teamFeed = "feed/getList"
    case teammateChat = "teammate/getChat"
    case wallet = "wallet/getOne"
    case feedChat = "feed/getChat"
    case feedCreateChat = "feed/newChat"
}

enum TeambrellaResponseType {
    case timestamp
    case initClient
    case updates
    case teams([TeamEntity], [TeamEntity], Int?)
    case teammatesList([TeammateLike])
    case teammate(ExtendedTeammate)
    case teammateVote(JSON)
    case newPost(ChatEntity)
    case registerKey
    case claimsList([ClaimLike])
    case claim(EnhancedClaimEntity)
    case claimVote(JSON)
    case claimUpdates(JSON)
    case home(HomeScreenModel)
    case teamFeed([FeedEntity])
    case chat(Int64, [ChatEntity], JSON)
    case wallet(WalletEntity)
}

typealias TeambrellaRequestSuccess = (_ result: TeambrellaResponseType) -> Void
typealias TeambrellaRequestFailure = (_ error: Error) -> Void

// swiftlint:disable function_body_length
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
        case .teams:
            let teams = TeamEntity.teams(with: reply["MyTeams"])
            let invitations = TeamEntity.teams(with: reply["MyInvitations"])
            let lastSelectedTeam = reply["LastSelectedTeam"].int
            success(.teams(teams, invitations, lastSelectedTeam))
        case .newPost:
            success(.newPost(ChatEntity(json: reply)))
        case .teammateVote:
            success(.teammateVote(reply))
        case .registerKey:
            success(.registerKey)
        case .claimsList:
            let claims = ClaimFactory.claims(with: reply)
            success(.claimsList(claims))
        case .claim:
            success(.claim(EnhancedClaimEntity(json: reply)))
        case .claimVote:
            success(.claimVote(reply))
        case .claimUpdates:
            success(.claimUpdates(reply))
        case .claimChat,
             .teammateChat,
             .feedChat,
             .feedCreateChat:
            let discussion = reply["DiscussionPart"]
            let lastRead = discussion["LastRead"].int64Value
            let chat = ChatEntity.buildArray(from: discussion["Chat"])
            let basicInfo = discussion["BasicPart"]
            success(.chat(lastRead, chat, basicInfo))
        case .teamFeed:
            success(.teamFeed(reply.arrayValue.flatMap { FeedEntity(json: $0) }))
        case .home:
            success(.home(HomeScreenModel(json: reply)))
        case .wallet:
            success(.wallet(WalletEntity(json: reply)))
        case .updates:
            break
        default:
            break
        }
    }
    
}
