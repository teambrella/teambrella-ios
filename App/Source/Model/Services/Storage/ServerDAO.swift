//
//  LocalStorage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

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

// swiftlint:disable type_body_length
class ServerDAO: DAO {
    struct Constant {
        static let avatarSize = 128
        static let proxyAvatarSize = 32
    }
    
    var lastKeyTime: Date?
    var recentScene: SceneType {
        get {
            if let stored = SimpleStorage().string(forKey: .recentScene) {
                return SceneType(rawValue: stored) ?? .home
            }
            return .home
        }
        set {
            SimpleStorage().store(string: newValue.rawValue, forKey: .recentScene)
        }
    }
    
    private var server: ServerService
    
    init(server: ServerService) {
        self.server = server
    }
    
    func requestTeams(demo: Bool) -> Future<TeamsModel> {
        let promise = Promise<TeamsModel>()
        let server = self.server
        freshKey { key in
            let body = RequestBody(key: key, payload: [:])
            let requestType: TeambrellaPostRequestType = demo ? .demoTeams : .teams
            let request = TeambrellaRequest(type: requestType, parameters: nil, body: body, success: { response in
                if case .teams(let teamsEntity) = response { promise.resolve(with: teamsEntity) }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: server)
        }
        return promise
    }
    
    func requestHome(teamID: Int) -> Future<HomeModel> {
        //let language = setLanguage()
        let promise = Promise<HomeModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .home, body: body, success: { response in
                if case let .home(model) = response {
                    service.session?.updateMyUser(with: model)
                    promise.resolve(with: model)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .home got \(response)"))
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func setLanguage() -> Future<String> {
        let promise = Promise<String>()
        freshKey { key in
            let body = RequestBody(key: key)
            let requestType: TeambrellaPostRequestType
            if let locale = Locale.current.languageCode, locale == "es" {
                requestType = .setLanguageEs
            } else {
                requestType = .setLanguageEn
            }
            let request = TeambrellaRequest(type: requestType,
                                            body: body,
                                            success: { response in
                                                if case let .setLanguage(language) = response {
                                                    log("Language is set to \(language)", type: .info)
                                                    promise.resolve(with: language)
                                                } else {
                                                    let errorMessage = "Was waiting .setLanguage got \(response)"
                                                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                                                         description: errorMessage))
                                                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func deleteCard(topicID: String) -> Future<HomeModel> {
        let promise = Promise<HomeModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["topicId": topicID])
            let request = TeambrellaRequest(type: .feedDeleteCard, body: body, success: { response in
                if case let .feedDeleteCard(homeModel) = response {
                    promise.resolve(with: homeModel)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .deleteCard got \(response)"))
                }
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestTeamFeed(context: FeedRequestContext, needTemporaryResult: Bool) -> Future<FeedChunk> {
        let promise = Promise<FeedChunk>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": context.teamID,
                                                       "StartIndex": context.startIndex,
                                                       "limit": context.limit,
                                                       "search": context.search ?? NSNull()])
            let request = TeambrellaRequest(type: .teamFeed, body: body, success: { response in
                if case let .teamFeed(chunk) = response {
                    promise.resolve(with: chunk)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .teamFeed, got \(response)"))
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestCoverage(for date: Date, teamID: Int) -> Future<CoverageForDate> {
        let promise = Promise<CoverageForDate>()
        let dateString = Formatter.teambrellaShortDashed.string(from: date)
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Date": dateString])
            let request = TeambrellaRequest(type: .coverageForDate, body: body, success: { response in
                if case let .coverageForDate(coverageForDate) = response {
                    promise.resolve(with: coverageForDate)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    // MARK: Wallet
    
    func requestWallet(teamID: Int) -> Future<WalletEntity> {
        let promise = Promise<WalletEntity>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .wallet, body: body, success: { response in
                if case .wallet(let wallet) = response {
                    promise.resolve(with: wallet)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server, isErrorAutoManaged: false)
        }
        return promise
    }
    
    func requestWalletTransactions(teamID: Int,
                                   offset: Int,
                                   limit: Int,
                                   search: String) -> Future<[WalletTransactionsModel]> {
        let promise = Promise<[WalletTransactionsModel]>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "offset": offset,
                                                       "limit": limit,
                                                       "search": search])
            let request = TeambrellaRequest(type: .walletTransactions, body: body, success: { response in
                if case let .walletTransactions(transactions) = response {
                    promise.resolve(with: transactions)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    // MARK: Proxy
    
    func requestMyProxiesList(teamID: Int, offset: Int, limit: Int) -> Future<[ProxyCellModel]> {
        let promise = Promise<[ProxyCellModel]>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Offset": offset,
                                                       "Limit": limit])
            let request = TeambrellaRequest(type: .myProxies, body: body, success: { response in
                if case let .myProxies(proxies) = response {
                    promise.resolve(with: proxies)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func updateProxyPosition(teamID: Int, userID: String, newPosition: Int) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "UserId": userID,
                                                       "Position": newPosition])
            let request = TeambrellaRequest(type: .proxyPosition, body: body, success: { response in
                if case .proxyPosition = response {
                    promise.resolve(with: true)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestProxyRating(teamID: Int,
                            offset: Int,
                            limit: Int,
                            searchString: String?,
                            sortBy: SortVC.SortType) -> Future<ProxyRatingEntity> {
        let promise = Promise<ProxyRatingEntity>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Offset": offset,
                                                       "Limit": limit,
                                                       "Search": searchString ?? "",
                                                       "SortBy": sortBy.rawValue])
            let request = TeambrellaRequest(type: .proxyRatingList, body: body, success: { response in
                if case let .proxyRatingList(proxyRatingEntity) = response {
                    promise.resolve(with: proxyRatingEntity)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestProxyFor(teamID: Int, offset: Int, limit: Int) -> Future<ProxyForEntity> {
        let promise = Promise<ProxyForEntity>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Offset": offset,
                                                       "Limit": limit])
            let request = TeambrellaRequest(type: .proxyFor, body: body, success: { response in
                if case let .proxyFor(proxyForEntity) = response { promise.resolve(with: proxyForEntity) }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    // MARK: Claims
    
    func updateClaimVote(claimID: Int, vote: Float?, lastUpdated: Int64) -> Future<ClaimVoteUpdate> {
        let promise = Promise<ClaimVoteUpdate>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["ClaimId": claimID,
                                                       "MyVote": vote ?? NSNull(),
                                                       "Since": lastUpdated,
                                                       "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claimVote, body: body, success: { response in
                if case let .claimVote(voteUpdate) = response { promise.resolve(with: voteUpdate) }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestClaimsList(teamID: Int, offset: Int, limit: Int, filterTeammateID: Int?) -> Future<[ClaimEntity]> {
        let promise = Promise<[ClaimEntity]>()
        freshKey { key in
            var payload: [String: Any] = ["TeamId": service.session?.currentTeam?.teamID ?? 0,
                                          "Offset": offset,
                                          "Limit": limit,
                                          "AvatarSize": Constant.avatarSize]
            if let teammateID = filterTeammateID {
                payload["TeammateIdFilter"] = teammateID
            }
            let body = RequestBody(key: key, payload: payload)
            let request = TeambrellaRequest(type: .claimsList, body: body, success: { response in
                if case let .claimsList(claims) = response {
                    promise.resolve(with: claims)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestClaim(claimID: Int) -> Future<ClaimEntityLarge> {
        let promise = Promise<ClaimEntityLarge>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["id": claimID,
                                                       "AvatarSize": Constant.avatarSize,
                                                       "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claim, body: body, success: { response in
                if case let .claim(claim) = response { promise.resolve(with: claim) }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestClaimTransactions(teamID: Int,
                                  claimID: Int,
                                  limit: Int,
                                  offset: Int) -> Future<[ClaimTransactionsModel]> {
        let promise = Promise<[ClaimTransactionsModel]>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "ClaimId": claimID,
                                                       "Limit": limit,
                                                       "Offset": offset])
            let request = TeambrellaRequest(type: .claimTransactions, body: body, success: { response in
                if case let .claimTransactions(transactions) = response {
                    promise.resolve(with: transactions)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    // MARK: Teammates
    
    func requestTeammatesList(teamID: Int,
                              offset: Int,
                              limit: Int,
                              isOrderedByRisk: Bool) -> Future<[TeammateListEntity]> {
        let promise = Promise<[TeammateListEntity]>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Offset": offset,
                                                       "Limit": limit,
                                                       "AvatarSize": Constant.avatarSize,
                                                       "OrderByRisk": isOrderedByRisk])
            let request = TeambrellaRequest(type: .teammatesList, body: body, success: { response in
                if case let .teammatesList(teammates) = response { promise.resolve(with: teammates) }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestTeammate(userID: String, teamID: Int) -> Future<TeammateLarge> {
        let promise = Promise<TeammateLarge>()
        freshKey { key in
            let body = RequestBody(key: key, payload: [
                "UserId": userID,
                "TeamId": teamID,
                "AfterVer": 0
                ])
            let request = TeambrellaRequest(type: .teammate, body: body, success: {response in
                if case let .teammate(teammate) = response {
                    promise.resolve(with: teammate)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestWithdrawTransactions(teamID: Int) -> Future<WithdrawChunk> {
        let promise = Promise<WithdrawChunk>()
        
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .withdrawTransactions, body: body, success: { response in
                if case let .withdrawTransactions(chunk) = response {
                    promise.resolve(with: chunk)
                } else {
                    let error = TeambrellaError(kind: .wrongReply,
                                                description: "Was waiting withdrawTransactions, got \(response)")
                    promise.reject(with: error)
                    service.error.present(error: error)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestTeammateOthersVoted(teamID: Int, teammateID: Int) -> Future<VotersList> {
        let promise = Promise<VotersList>()
        
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "TeammateId": teammateID])
            let request = TeambrellaRequest(type: .teammateVotesList, body: body, success: { response in
                if case let .votesList(votesList) = response {
                    promise.resolve(with: votesList)
                } else {
                    let error = TeambrellaError(kind: .wrongReply,
                                                description: "Was waiting votesList, got \(response)")
                    promise.reject(with: error)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestClaimOthersVoted(teamID: Int, claimID: Int) -> Future<VotersList> {
        let promise = Promise<VotersList>()
        
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "ClaimId": claimID])
            let request = TeambrellaRequest(type: .claimVotesList, body: body, success: { response in
                if case let .votesList(votesList) = response {
                    promise.resolve(with: votesList)
                } else {
                    let error = TeambrellaError(kind: .wrongReply,
                                                description: "Was waiting votesList, got \(response)")
                    promise.reject(with: error)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestChat(type: TeambrellaPostRequestType, body: RequestBody) -> Future<TeambrellaResponseType> {
        let promise = Promise<TeambrellaResponseType>()
        freshKey { key in
            let request = TeambrellaRequest(type: type, body: body, success: { response in
                promise.resolve(with: response)
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func withdraw(teamID: Int, amount: Double, address: EthereumAddress) -> Future<WithdrawChunk> {
        let promise = Promise<WithdrawChunk>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Amount": amount,
                                                       "ToAddress": address.string])
            let request = TeambrellaRequest(type: .withdraw, body: body, success: { response in
                if case let .withdrawTransactions(chunk) = response {
                    promise.resolve(with: chunk)
                } else {
                    let error = TeambrellaError(kind: .wrongReply,
                                                description: "Was waiting withdrawTransactions, got \(response)")
                    promise.reject(with: error)
                    service.error.present(error: error)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func myProxy(userID: String, add: Bool) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["UserId": userID,
                                                       "add": add])
            let request = TeambrellaRequest(type: .myProxy, body: body, success: { response in
                if case .myProxy(let isProxy) = response {
                    promise.resolve(with: isProxy)
                } else {
                    let error = TeambrellaError(kind: .wrongReply,
                                                description: "Was waiting .myProxy, got \(response)")
                    promise.reject(with: error)
                    service.error.present(error: error)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func sendPhoto(data: Data) -> Future<String> {
        let promise = Promise<String>()
        freshKey { key in
            var body = RequestBody(key: key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = data
            let request = TeambrellaRequest(type: .uploadPhoto, body: body, success: { response in
                if case .uploadPhoto(let name) = response {
                    promise.resolve(with: name)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func sendRiskVote(teammateID: Int, risk: Double?) -> Future<TeammateVotingResult> {
        let promise = Promise<TeammateVotingResult>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeammateId": teammateID,
                                                       "MyVote": risk ?? NSNull(),
                                                       "Since": key.timestamp,
                                                       "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .teammateVote, body: body, success: { response in
                if case let .teammateVote(votingResult) = response {
                    promise.resolve(with: votingResult)
                }
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func createNewClaim(model: NewClaimModel) -> Future<ClaimEntityLarge> {
        let promise = Promise<ClaimEntityLarge>()
        freshKey { key in
            let dateString = Formatter.teambrellaShortDashed.string(from: model.incidentDate)
            let body = RequestBody(key: key, payload: ["TeamId": model.teamID,
                                                       "IncidentDate": dateString,
                                                       "Expenses": model.expenses,
                                                       "Message": model.text,
                                                       "Images": model.images,
                                                       "Address": model.address])
            let request = TeambrellaRequest(type: .newClaim, body: body, success: { response in
                if case .claim(let claim) = response {
                    promise.resolve(with: claim)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func createNewChat(model: NewChatModel) -> Future<ChatModel> {
        let promise = Promise<ChatModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": model.teamID,
                                                       "Text": model.text,
                                                       "Title": model.title])
            let request = TeambrellaRequest(type: .newChat, body: body, success: { response in
                if case .chat(let chat) = response {
                    promise.resolve(with: chat)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }

    // TMP: remove when possible
    func performRequest(request: TeambrellaRequest) {
        request.start(server: server)
    }
    
    func mute(topicID: String, isMuted: Bool) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TopicId": topicID,
                                                       "IsMuted": isMuted])
            let request = TeambrellaRequest(type: .mute, body: body, success: { response in
                if case let .mute(success) = response {
                    promise.resolve(with: success)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestPrivateList(offset: Int, limit: Int, filter: String?) -> Future<[PrivateChatUser]> {
        let promise = Promise<[PrivateChatUser]>()
        freshKey { key in
            var payload: [String: Any] = ["Offset": offset,
                                          "Limit": limit]
            filter.map { payload["Search"] = $0 }
            let body = RequestBody(key: key, payload: payload)
            let request = TeambrellaRequest(type: .privateList, body: body, success: { response in
                if case .privateList(let users) = response {
                    promise.resolve(with: users)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start(server: self.server)
        }
        return promise
    }
    
    func registerKey(facebookToken: String, signature: String) -> Future<Bool> {
        let payload: [String: String] = ["facebookToken": facebookToken,
                                         "sigOfPublicKey": signature]
        return registerKey(payload: payload)
    }

    func registerKey(socialToken: String, signature: String) -> Future<Bool> {
        let payload: [String: String] = ["auth0Token": socialToken,
                                         "sigOfPublicKey": signature]
        return registerKey(payload: payload)
    }

    func registerKey(payload: [String: String]) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: payload)
            let request = TeambrellaRequest(type: .registerKey,
                                            body: body,
                                            success: { response in
                                                promise.resolve(with: true)
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func freshKey(completion: @escaping (Key) -> Void) {
        if let time = lastKeyTime, Date().timeIntervalSince(time) < 60.0 * 10.0 {
            completion(server.key)
        } else {
            self.server.updateTimestamp(completion: { _, _ in
                defer { self.lastKeyTime = Date() }
                completion(self.server.key)
            })
        }
    }
    
    func getCars(string: String?) -> Future<[String]> {
    return getQuery(string: string, type: .cars)
    }
    
    func getCities(string: String?) -> Future<[String]> {
       return getQuery(string: string, type: .cities)
    }
    
    private func getQuery(string: String?, type: TeambrellaGetRequestType) -> Future<[String]> {
        let promise = Promise<[String]>()
        guard let string = string else {
            defer {
                promise.resolve(with: [])
            }
            return promise
        }
        
        let request = TeambrellaGetRequest<[String]>(type: type,
                                                     parameters: ["q": string],
                                                     success: promise.resolve,
                                                     failure: promise.reject)
        request.start(server: self.server)
        return promise
    }
    
}
