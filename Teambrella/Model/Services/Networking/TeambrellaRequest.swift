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

typealias TeambrellaRequestSuccess = (_ result: TeambrellaResponseType) -> Void
typealias TeambrellaRequestFailure = (_ error: Error) -> Void

// swiftlint:disable function_body_length
struct TeambrellaRequest {
    let type: TeambrellaRequestType
    var parameters: [String: String]?
    let success: TeambrellaRequestSuccess
    var failure: TeambrellaRequestFailure?
    var body: RequestBody?
    
    private var requestString: String {
        switch type {
        case .demoTeams:
            if let locale = Locale.current.languageCode {
                return type.rawValue + "/" + locale
            }
        default:
            break
        }
        return type.rawValue
    }
    
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
    
    func start(isErrorAutoManaged: Bool = true) {
        service.server.ask(for: requestString, parameters: parameters, body: body, success: { serverReply in
            self.parseReply(serverReply: serverReply)
        }, failure: { error in
            log("\(error)", type: [.error, .serverReply])
            if isErrorAutoManaged {
                service.error.present(error: error)
            }
            self.failure?(error)
        })
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func parseReply(serverReply: ServerReply) {
        // temporary item for compatibility with legacy code
        let reply = JSON(serverReply.json)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.teambrella)
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "PositiveInfinity",
                                                                        negativeInfinity: "NegativeInfinity",
                                                                        nan: "NaN")

        switch type {
        case .timestamp:
            success(.timestamp)
        case .teammatesList:
            do {
                let list = try decoder.decode(TeammatesList.self, from: serverReply.data)
                print("my id: \(list.myTeammateID); team: \(list.teamID); count: \(list.teammates.count)")
                success(.teammatesList(list.teammates))
            } catch {
                print(error)
                failure?(error)
            }
        case .teammate:
            let teammate = TeammateLarge(json: reply)
            success(.teammate(teammate))
        case .teams, .demoTeams:
            do {
                let teamsModel = try decoder.decode(TeamsModel.self, from: serverReply.data)
                print(teamsModel)
                success(.teams(teamsModel))
            } catch {
                log(error)
                failure?(error)
            }
        case .newPost:
            success(.newPost(ChatEntity(json: reply)))
        case .teammateVote:
            do {
                let teamVotingResult = try decoder.decode(TeammateVotingResult.self, from: serverReply.data)
                success(.teammateVote(teamVotingResult))
            } catch {
                failure?(error)
            }
        case .registerKey:
            success(.registerKey)
        case .coverageForDate:
            success(.coverageForDate(reply["Coverage"].doubleValue, reply["LimitAmount"].doubleValue))
        case .setLanguageEn,
             .setLanguageEs:
            success(.setLanguage(reply.stringValue))
        case .claimsList:
            do {
                let claims = try decoder.decode([ClaimEntity].self, from: serverReply.data)
                success(.claimsList(claims))
            } catch {
                log(error)
                failure?(error)
            }
        case .claim,
             .newClaim:
            success(.claim(EnhancedClaimEntity(json: reply)))
        case .claimVote:
            success(.claimVote(reply))
        case .claimUpdates:
            success(.claimUpdates(reply))
        case .claimChat,
             .teammateChat,
             .feedChat,
             .newChat,
             .privateChat,
             .newPrivatePost:
            let chat: [ChatEntity]
            if type == .privateChat || type == .newPrivatePost {
                chat = PrivateChatAdaptor(json: reply).adaptedMessages
            } else {
                chat = ChatEntity.buildArray(from: reply["DiscussionPart"]["Chat"])
            }
            let model = ChatModel(json: reply, chat: chat)
            success(.chat(model))
        case .teamFeed:
            guard let pagingInfo = serverReply.paging else {
                failure?(TeambrellaErrorFactory.wrongReply())
                return
            }
            do {
                let feed = try decoder.decode([FeedEntity].self, from: serverReply.data)
                let chunk = FeedChunk(feed: feed, pagingInfo: pagingInfo)
                success(.teamFeed(chunk))
            } catch {
                failure?(error)
            }
        case .claimTransactions:
            do {
                let models = try decoder.decode([ClaimTransactionsCellModel].self, from: serverReply.data)
                success(.claimTransactions(models))
            } catch {
                log(error)
                failure?(error)
            }
        case .home:
            do {
                let model = try decoder.decode(HomeModel.self, from: serverReply.data)
                success(.home(model))
            } catch {
                log(error)
                failure?(error)
            }
        case .feedDeleteCard:
            do {
                let model = try decoder.decode(HomeModel.self, from: serverReply.data)
                success(.feedDeleteCard(model))
            } catch {
                failure?(error)
            }
        case .wallet:
            do {
                let model = try decoder.decode(WalletEntity.self, from: serverReply.data)
                success(.wallet(model))
            } catch {
                log(error)
                failure?(error)
            }
        case .walletTransactions:
            print(reply)
            do {
                let models = try decoder.decode([WalletTransactionsModel].self, from: serverReply.data)
                success(.walletTransactions(models))
            } catch {
                log(error)
                failure?(error)
            }
        case .updates:
            break
        case .uploadPhoto:
            success(.uploadPhoto(reply.arrayValue.first?.string ?? ""))
        case .myProxy:
            success(.myProxy(reply.stringValue == "set"))
        case .myProxies:
            do {
                let model = try decoder.decode([ProxyCellModel].self, from: serverReply.data)
                success(.myProxies(model))
            } catch {
                log(error)
                failure?(error)
            }
        case .proxyFor:
            do {
                let proxyForEntity = try decoder.decode(ProxyForEntity.self, from: serverReply.data)
                success(.proxyFor(proxyForEntity))
            } catch {
                log(error)
                failure?(error)
            }
        case .proxyPosition:
            success(.proxyPosition)
        case .proxyRatingList:
            do {
                let proxyRatingEntity = try decoder.decode(ProxyRatingEntity.self, from: serverReply.data)
                success(.proxyRatingList(proxyRatingEntity))
            } catch {
                log(error)
                failure?(error)
            }
        case .privateList:
            do {
                let model = try decoder.decode([PrivateChatUser].self, from: serverReply.data)
                success(.privateList(model))
            } catch {
                log(error)
                failure?(error)
            }
        case .withdrawTransactions,
             .withdraw:
            do {
                let chunk = try decoder.decode(WithdrawChunk.self, from: serverReply.data)
                success(.withdrawTransactions(chunk))
            } catch {
                failure?(error)
            }
        case .mute:
            success(.mute(reply.boolValue))
        case .claimVotesList,
             .teammateVotesList:
            do {
                let votesList = try JSONDecoder().decode(VotersList.self, from: serverReply.data)
                success(.votesList(votesList))
            } catch {
                failure?(error)
                print("votes eroor: \(error)")
            }
        default:
            break
        }
    }
    
}
