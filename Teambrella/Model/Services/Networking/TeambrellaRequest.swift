//
//  TeambrellaRequest.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.03.17.

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

import Foundation
import SwiftyJSON

enum TeambrellaRequestType: String {
    case timestamp = "me/GetTimestamp"
    case initClient = "me/InitClient"
    case updates = "me/GetUpdates"
    case teams = "me/getTeams"
    case registerKey = "me/registerKey"
    case coverageForDate = "me/getCoverageForDate"
    case setLanguageEn = "me/setUiLang/en"
    case setLanguageEs = "me/setUiLang/es"
    case teammatesList = "teammate/getList"
    case teammate = "teammate/getOne"
    case teammateVote = "teammate/setVote"
    case teammateChat = "teammate/getChat"      ///
    case newPost = "post/newPost"
    case claimsList = "claim/getList"
    case claim = "claim/getOne"
    case claimVote = "claim/setVote"
    case claimUpdates = "claim/getUpdates"
    case claimChat = "claim/getChat"            ///
    case home = "feed/getHome"                  ///////
    case feedDeleteCard = "feed/delCard"
    case teamFeed = "feed/getList"
    case feedChat = "feed/getChat"              ///
    case feedCreateChat = "feed/newChat"
    case wallet = "wallet/getOne"
    case uploadPhoto = "post/newUpload"
    case myProxy = "proxy/setMyProxy"
    case myProxies = "proxy/getMyProxiesList"
    case proxyFor = "proxy/getIAmProxyForList"
    case proxyPosition = "proxy/setMyProxyPosition"
    case proxyRatingList = "proxy/getRatingList"
}

enum TeambrellaResponseType {
    case timestamp
    case initClient
    case updates
    case teams([TeamEntity], [TeamEntity], String, Int?)
    case teammatesList([TeammateLike])
    case teammate(ExtendedTeammate)
    case teammateVote(JSON)
    case newPost(ChatEntity)
    case registerKey
    case coverageForDate(Double, Double)
    case setLanguage(String)
    case claimsList([ClaimLike])
    case claim(EnhancedClaimEntity)
    case claimVote(JSON)
    case claimUpdates(JSON)
    case home(HomeScreenModel) //
    case feedDeleteCard(HomeScreenModel)
    case teamFeed([FeedEntity])
    case chat(lastRead: Int64, chat: [ChatEntity], basicPart: JSON, teamPart: JSON) //
    case wallet(WalletEntity)
    case uploadPhoto(String)
    case myProxy(Bool)
    case myProxies([ProxyCellModel])
    case proxyFor([ProxyForCellModel], Double)
    case proxyPosition
    case proxyRatingList([UserIndexCellModel], Int)
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
            let userID = reply["UserId"].stringValue
            success(.teams(teams, invitations, userID, lastSelectedTeam))
        case .newPost:
            success(.newPost(ChatEntity(json: reply)))
        case .teammateVote:
            success(.teammateVote(reply))
        case .registerKey:
            success(.registerKey)
        case .coverageForDate:
            success(.coverageForDate(reply["Coverage"].doubleValue, reply["LimitAmount"].doubleValue))
        case .setLanguageEn,
             .setLanguageEs:
            success(.setLanguage(reply.stringValue))
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
            let teamPart = discussion["TeamPart"]
            success(.chat(lastRead: lastRead, chat: chat, basicPart: basicInfo, teamPart: teamPart))
        case .teamFeed:
            success(.teamFeed(reply.arrayValue.flatMap { FeedEntity(json: $0) }))
        case .home:
            success(.home(HomeScreenModel(json: reply)))
        case .feedDeleteCard:
            success(.feedDeleteCard(HomeScreenModel(json: reply)))
        case .wallet:
            success(.wallet(WalletEntity(json: reply)))
        case .updates:
            break
        case .uploadPhoto:
            success(.uploadPhoto(reply.arrayValue.first?.string ?? ""))
        case .myProxy:
            success(.myProxy(reply.stringValue == "set"))
        case .myProxies:
            let models = reply.arrayValue.map { ProxyCellModel(json: $0) }
            success(.myProxies(models))
        case .proxyFor:
            let models = reply["Members"].arrayValue.map { ProxyForCellModel(json: $0) }
            success(.proxyFor(models, reply["TotalCommission"].doubleValue))
        case .proxyPosition:
            success(.proxyPosition)
        case .proxyRatingList:
            let models = reply["Members"].arrayValue.map { UserIndexCellModel(json: $0) }
            success(.proxyRatingList(models, reply["TotalCount"].intValue))
        default:
            break
        }
    }
    
}
