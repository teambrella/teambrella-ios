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

import ExtensionsPack
import Foundation

typealias TeambrellaRequestSuccess = (_ result: TeambrellaResponseType) -> Void
typealias TeambrellaRequestFailure = (_ error: Error) -> Void

private var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.teambrella)
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "PositiveInfinity",
                                                                    negativeInfinity: "NegativeInfinity",
                                                                    nan: "NaN")
    return decoder
}()

struct TeambrellaGetRequest<Value: Decodable> {
    let type: TeambrellaGetRequestType
    var parameters: [String: String]
    let success: (Value) -> Void
    var failure: ((Error) -> Void)?
    
    func start(server: ServerService) {
        server.get(string: type.rawValue, parameters: parameters, success: self.parseReply, failure: self.handleError)
    }
    
    func parseReply(data: Data) {
        do {
            let value = try decoder.decode(Value.self, from: data)
            success(value)
        } catch {
            handleError(error: error)
        }
    }
    
    func handleError(error: Error) {
        failure?(error)
    }
}

// swiftlint:disable function_body_length
struct TeambrellaRequest<Value: Decodable> {
    let type: TeambrellaPostRequestType
    var parameters: [String: String]?
    let success: (ServerReplyBox<Value>) -> Void
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
    
    func start(server: ServerService, isErrorAutoManaged: Bool = true) {
        server.ask(for: requestString, parameters: parameters, body: body, success: { reply in
            self.parseReply(server: server, reply: reply)
        }, failure: { error in
            log("\(error)", type: [.error, .serverReply])
            if isErrorAutoManaged {
                service.error.present(error: error)
            }
            self.failure?(error)
        })
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func parseReply(server: ServerService, reply: Data) {
        do {
            let box = try decoder.decode(ServerReplyBox<Value>.self, from: reply)
            server.timestamp = box.status.timestamp
            if box.status.isError {
            // handle error
            } else {
            success(box)
            }
        } catch {
            failure?(error)
        }
    }
     /*
        log("Server reply: \(serverReply.json)", type: .serverReply)
        //decoder.keyDecodingStrategy = .convertFromUpperCamelCase
        log("Reply type: \(type)", type: .serverReplyStats)
        do {
            switch type {
            case .timestamp:
                success(.timestamp)
            case .teammatesList:
                let list = try decoder.decode(TeammatesList.self, from: serverReply.data)
                log("my id: \(list.myTeammateID); team: \(list.teamID); count: \(list.teammates.count)",
                    type: .serverReplyStats)
                success(.teammatesList(list.teammates))
            case .teammate:
                let teammate = try decoder.decode(TeammateLarge.self, from: serverReply.data)
                log("teammate: \(teammate.basic.id)", type: .serverReplyStats)
                success(.teammate(teammate))
            case .teams, .demoTeams:
                let teamsModel = try decoder.decode(TeamsModel.self, from: serverReply.data)
                log("teamsModel: \(teamsModel)", type: .serverReplyStats)
                success(.teams(teamsModel))
            case .newPost:
                let entity = try decoder.decode(ChatEntity.self, from: serverReply.data)
                log("chat entity id: \(entity.id)", type: .serverReplyStats)
                success(.newPost(entity))
            case .teammateVote:
                let teamVotingResult = try decoder.decode(TeammateVotingResult.self, from: serverReply.data)
                log("teammmate voting result id: \(teamVotingResult.id)", type: .serverReplyStats)
                success(.teammateVote(teamVotingResult))
            case .registerKey,
                 .joinRregisterKey:
                success(.registerKey)
            case .coverageForDate:
                let coverageForDate = try decoder.decode(CoverageForDate.self, from: serverReply.data)
                success(.coverageForDate(coverageForDate))
            case .setLanguageEn,
                 .setLanguageEs:
                guard let language = serverReply.string else {
                    log("SetLanguage wrong reply", type: .error)
                    failure?(TeambrellaErrorFactory.wrongReply())
                    return
                }
                
                log("language: \(language)", type: .serverReplyStats)
                success(.setLanguage(language))
            case .claimsList:
                let claims = try decoder.decode([ClaimEntity].self, from: serverReply.data)
                log("claims count: \(claims.count)", type: .serverReplyStats)
                success(.claimsList(claims))
            case .claim,
                 .newClaim:
                let claim = try decoder.decode(ClaimEntityLarge.self, from: serverReply.data)
                log("claim: \(claim)", type: .serverReplyStats)
                success(.claim(claim))
            case .claimVote:
                let claimUpdate = try decoder.decode(ClaimVoteUpdate.self, from: serverReply.data)
                log("claim update: \(claimUpdate)", type: .serverReplyStats)
                success(.claimVote(claimUpdate))
            case .claimChat,
                 .teammateChat,
                 .feedChat,
                 .newChat,
                 .privateChat,
                 .newPrivatePost:
                let model = try decoder.decode(ChatModel.self, from: serverReply.data)
                log("ChatModel: \(model)", type: .serverReplyStats)
                success(.chat(model))
            case .teamFeed:
                guard let pagingInfo = serverReply.paging else {
                    failure?(TeambrellaErrorFactory.noPagingInfo())
                    return
                }
                
                let feed = try decoder.decode([FeedEntity].self, from: serverReply.data)
                let chunk = FeedChunk(feed: feed, pagingInfo: pagingInfo)
                log("feed with items count: \(chunk.feed.count)", type: .serverReplyStats)
                success(.teamFeed(chunk))
            case .claimTransactions:
                let models = try decoder.decode([ClaimTransactionsModel].self, from: serverReply.data)
                log("claim transactions count: \(models.count)", type: .serverReplyStats)
                success(.claimTransactions(models))
            case .home:
                let model = try decoder.decode(HomeModel.self, from: serverReply.data)
                success(.home(model))
            case .feedDeleteCard:
                let model = try decoder.decode(HomeModel.self, from: serverReply.data)
                success(.feedDeleteCard(model))
            case .wallet:
                let model = try decoder.decode(WalletEntity.self, from: serverReply.data)
                success(.wallet(model))
            case .walletTransactions:
                let models = try decoder.decode([WalletTransactionsModel].self, from: serverReply.data)
                success(.walletTransactions(models))
            case .updates:
                break
            case .uploadPhoto:
                let photoAddresses = try decoder.decode([String].self, from: serverReply.data)
                success(.uploadPhoto(photoAddresses.first ?? ""))
            case .myProxy:
                guard let string = serverReply.string else {
                    log("MyProxy wrong reply", type: .error)
                    failure?(TeambrellaErrorFactory.wrongReply())
                    return
                }
                
                let isGoodReply = string == "Proxy voter is added." || string == "Proxy voter is removed."
                success(.myProxy(isGoodReply))
            case .myProxies:
                let model = try decoder.decode([ProxyCellModel].self, from: serverReply.data)
                success(.myProxies(model))
            case .proxyFor:
                let proxyForEntity = try decoder.decode(ProxyForEntity.self, from: serverReply.data)
                success(.proxyFor(proxyForEntity))
            case .proxyPosition:
                success(.proxyPosition)
            case .proxyRatingList:
                let proxyRatingEntity = try decoder.decode(ProxyRatingEntity.self, from: serverReply.data)
                success(.proxyRatingList(proxyRatingEntity))
            case .privateList:
                let model = try decoder.decode([PrivateChatUser].self, from: serverReply.data)
                success(.privateList(model))
            case .withdrawTransactions,
                 .withdraw:
                let chunk = try decoder.decode(WithdrawChunk.self, from: serverReply.data)
                success(.withdrawTransactions(chunk))
            case .mute:
                guard let bool = serverReply.bool else {
                    log("Mute wrong reply", type: .error)
                    failure?(TeambrellaErrorFactory.wrongReply())
                    return
                }
                
                success(.mute(bool))
            case .claimVotesList,
                 .teammateVotesList:
                let votesList = try decoder.decode(VotersList.self, from: serverReply.data)
                success(.votesList(votesList))
            case .me:
                let myModel = try decoder.decode(MeModel.self, from: serverReply.data)
                success(.me(myModel))
            case .welcome:
                let welcome = try decoder.decode(WelcomeEntity.self, from: serverReply.data)
                success(.welcome(welcome))
            default:
                break
            }
        } catch {
            log(error)
            failure?(error)
        }
    }
    */
}
