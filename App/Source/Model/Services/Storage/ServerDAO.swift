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
        if demo, let locale = Locale.current.languageCode {
            let suffix = locale
            return startRequest(body: [:],
                                type: .demoTeams,
                                suffix: suffix,
                                isErrorAutoManaged: false
            )
        } else {
            return startRequest(body: [:], type: .teams, isErrorAutoManaged: false)
        }
    }
    
    func requestHome(teamID: Int) -> Future<HomeModel> {
        //let language = setLanguage()
        let promise = Promise<HomeModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest<HomeModel>(type: .home,
                                                       body: body,
                                                       success: { box in
                                                        guard let value = box.value else {
                                                            fatalError()
                                                        }
                                                        
                                                        service.session?.updateMyUser(with: value)
                                                        promise.resolve(with: value)
            },
                                                       failure: promise.reject)
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
            let request = TeambrellaRequest<String>(type: requestType,
                                                    body: body,
                                                    success: { box in
                                                        guard let value = box.value else {
                                                            fatalError()
                                                        }
                                                        
                                                        log("Language is set to \(value)", type: .info)
                                                        promise.resolve(with: value)
                                                        
            }, failure: { error in promise.reject(with: error) })
            request.start(server: self.server)
        }
        return promise
    }
    
    func deleteCard(topicID: String) -> Future<HomeModel> {
        return startRequest(body: ["topicId": topicID], type: .feedDeleteCard)
    }
    
    func requestTeamFeed(context: FeedRequestContext, needTemporaryResult: Bool) -> Future<FeedChunk> {
        let promise = Promise<FeedChunk>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": context.teamID,
                                                       "StartIndex": context.startIndex,
                                                       "limit": context.limit,
                                                       "search": context.search ?? NSNull()])
            let request = TeambrellaRequest<[FeedEntity]>(type: .teamFeed,
                                                          body: body, success: { box in
                                                            guard let value = box.value else {
                                                                fatalError()
                                                            }
                                                            
                                                            let chunk = FeedChunk(feed: value,
                                                                                  pagingInfo: box.paging)
                                                            promise.resolve(with: chunk)
            }, failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestCoverage(for date: Date, teamID: Int) -> Future<CoverageForDate> {
        let dateString = Formatter.teambrellaShortDashed.string(from: date)
        return startRequest(body: ["TeamId": teamID,
                                   "Date": dateString],
                            type: .coverageForDate)
    }
    
    // MARK: Wallet
    
    func requestWallet(teamID: Int) -> Future<WalletEntity> {
        let promise = Promise<WalletEntity>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = self.standardRequest(promise: promise, type: .wallet, body: body)
            request.start(server: self.server, isErrorAutoManaged: false)
        }
        return promise
    }
    
    func requestWalletTransactions(teamID: Int,
                                   offset: Int,
                                   limit: Int,
                                   search: String) -> Future<[WalletTransactionsModel]> {
        return startRequest(body: ["TeamId": teamID,
                                   "offset": offset,
                                   "limit": limit,
                                   "search": search],
                            type: .walletTransactions)
    }
    
    // MARK: Proxy
    
    func requestMyProxiesList(teamID: Int, offset: Int, limit: Int) -> Future<[ProxyCellModel]> {
        return startRequest(body: ["TeamId": teamID,
                                   "Offset": offset,
                                   "Limit": limit],
                            type: .myProxies)
    }
    
    func updateProxyPosition(teamID: Int, userID: String, newPosition: Int) -> Future<Bool> {
        let promise = Promise<Bool>()
        
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "UserId": userID,
                                                       "Position": newPosition])
            let request = TeambrellaRequest<String>(type: .proxyPosition, body: body, success: { box in
                guard let value = box.value else {
                    fatalError()
                }
                
                switch value.lowercased() {
                case "ok":
                    promise.resolve(with: true)
                default:
                    promise.resolve(with: false)
                }
            }, failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestProxyRating(teamID: Int,
                            offset: Int,
                            limit: Int,
                            searchString: String?,
                            sortBy: SortVC.SortType) -> Future<ProxyRatingEntity> {
        return startRequest( body: ["TeamId": teamID,
                                    "Offset": offset,
                                    "Limit": limit,
                                    "Search": searchString ?? "",
                                    "SortBy": sortBy.rawValue],
                             type: .proxyRatingList)
    }
    
    func requestProxyFor(teamID: Int, offset: Int, limit: Int) -> Future<ProxyForEntity> {
        return startRequest(body: ["TeamId": teamID,
                                   "Offset": offset,
                                   "Limit": limit],
                            type: .proxyFor)
    }
    
    // MARK: Claims
    
    func updateClaimVote(claimID: Int, vote: Float?, lastUpdated: Int64) -> Future<ClaimVoteUpdate> {
        return startRequest( body: ["ClaimId": claimID,
                                    "MyVote": vote ?? NSNull(),
                                    "Since": lastUpdated,
                                    "ProxyAvatarSize": Constant.proxyAvatarSize],
                             type: .claimVote)
    }
    
    func requestClaimsList(teamID: Int, offset: Int, limit: Int, filterTeammateID: Int?) -> Future<[ClaimEntity]> {
        var payload: [String: Any] = ["TeamId": teamID,
                                      "Offset": offset,
                                      "Limit": limit,
                                      "AvatarSize": Constant.avatarSize]
        if let teammateID = filterTeammateID {
            payload["TeammateIdFilter"] = teammateID
        }
        return startRequest(body: payload, type: .claimsList)
    }

    func requestClaim(claimID: Int) -> Future<ClaimEntityLarge> {
        return startRequest(body: ["id": claimID,
                                   "AvatarSize": Constant.avatarSize,
                                   "ProxyAvatarSize": Constant.proxyAvatarSize],
                            type: .claim)
    }
    
    func requestClaimTransactions(teamID: Int,
                                  claimID: Int,
                                  limit: Int,
                                  offset: Int) -> Future<[ClaimTransactionsModel]> {
        return startRequest(body: ["TeamId": teamID,
                                   "ClaimId": claimID,
                                   "Limit": limit,
                                   "Offset": offset],
                            type: .claimTransactions)
    }
    
    // MARK: Teammates
    
    func requestTeammatesList(teamID: Int,
                              offset: Int,
                              limit: Int,
                              isOrderedByRisk: Bool) -> Future<(TeammatesList, PagingInfo?)> {
        let promise = Promise<(TeammatesList, PagingInfo?)>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Offset": offset,
                                                       "Limit": limit,
                                                       "AvatarSize": Constant.avatarSize,
                                                       "OrderByRisk": isOrderedByRisk])
            let request = TeambrellaRequest<TeammatesList>(type: .teammatesList, body: body, success: { box in
                guard let value = box.value else {
                    fatalError()
                }
                
                promise.resolve(with: (value, box.paging))
            }, failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }
    
    func requestTeammate(userID: String, teamID: Int) -> Future<TeammateLarge> {
        return startRequest(body: [
            "UserId": userID,
            "TeamId": teamID,
            "AfterVer": 0
            ], type: .teammate)
    }
    
    func requestWithdrawTransactions(teamID: Int) -> Future<WithdrawChunk> {
        return startRequest(body: ["TeamId": teamID],
                            type: .withdrawTransactions)
    }
    
    func requestTeammateOthersVoted(teamID: Int, teammateID: Int) -> Future<VotersList> {
        return startRequest(body: ["TeamId": teamID,
                                   "TeammateId": teammateID],
                            type: .teammateVotesList)
    }
    
    func requestClaimOthersVoted(teamID: Int, claimID: Int) -> Future<VotersList> {
        return startRequest(body: ["TeamId": teamID,
                                   "ClaimId": claimID],
                            type: .claimVotesList)
    }
    
    func requestClaimsVotesList(teamID: Int, offset: Int, limit: Int, votesOfTeammateID: Int) -> Future<[ClaimEntity]> {
        let payload: [String: Any] = ["TeamId": teamID,
                                      "Offset": offset,
                                      "Limit": limit,
                                      "VotesOfTeammateID": votesOfTeammateID,
                                      "AvatarSize": Constant.avatarSize]
        return startRequest(body: payload, type: .claimsList)
    }
    
    func requestRisksVotesList(teamID: Int, offset: Int, limit: Int, teammateID: Int) -> Future<RiskVotesList> {
        let payload: [String: Any] = ["TeamId": teamID,
                                      "Offset": offset,
                                      "Limit": limit,
                                      "teammateID": teammateID,
                                      "AvatarSize": Constant.avatarSize]
        return startRequest(body: payload, type: .riskVotesList)
    }


    func requestChat(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel> {
        return startRequest(body: body, type: type)
    }
    
    func sendChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatEntity> {
        return startRequest(body: body, type: type)
    }
    
    func sendPrivateChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel> {
        return startRequest(body: body, type: type)
    }
    
    func withdraw(teamID: Int, amount: Double, address: EthereumAddress) -> Future<WithdrawChunk> {
        return startRequest(body: ["TeamId": teamID,
                                   "Amount": amount,
                                   "ToAddress": address.string],
                            type: .withdraw)
    }
    
    func myProxy(userID: String, add: Bool) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["UserId": userID,
                                                       "add": add])
            let request = TeambrellaRequest<String>(type: .myProxy, body: body, success: { box in
                switch box.value {
                case "Proxy voter is added.",
                     "Proxy voter is removed.":
                    promise.resolve(with: true)
                default:
                    promise.resolve(with: false)
                }
            }, failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }
    
    func sendPhoto(data: Data) -> Future<[String]> {
        let promise = Promise<[String]>()
        freshKey { key in
            var body = RequestBody(key: key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = data
            let request = TeambrellaRequest<[String]>(type: .uploadPhoto, body: body, success: { box in
                guard let value = box.value else {
                    fatalError()
                }

                promise.resolve(with: value) },
                                                      failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }

    func sendPhotoPost(topicID: String, postID: String, isCertified: Bool, data: Data) -> Future<ChatEntity> {
        let promise = Promise<ChatEntity>()
        freshKey { key in
            var body = RequestBody(key: key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = data

            var parameters = ["PostId": postID]
            if isCertified {
                parameters["cam"] = "X"
            }
            var request = TeambrellaRequest<ChatEntity>(type: .newPhotoPost,
                                                        parameters: parameters,
                                                        body: body,
                                                        success: { box in
                guard let value = box.value else { fatalError() }

                promise.resolve(with: value)
            },
                                                        failure: promise.reject)
            request.suffix = topicID
            request.start(server: self.server)
        }
        return promise
    }
    
    func sendAvatar(data: Data) -> Future<String> {
        let promise = Promise<String>()
        freshKey { key in
            var body = RequestBody(key: key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = data
            let request = TeambrellaRequest<[String: String]>(type: .uploadAvatar,
                                                              body: body,
                                                              success: { box in
                                                                guard let avatar = box.value?["Avatar"] else {
                                                                    let error = TeambrellaErrorFactory.wrongReply()
                                                                    promise.reject(with: error)
                                                                    return  }
                                                                
                                                                promise.resolve(with: avatar)
            },
                                                              failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }

    func deletePost(id: String) -> Future<String> {
        return startRequest(body: ["id": id], type: .deletePost)
    }
    
    func sendRiskVote(teammateID: Int, risk: Double?) -> Future<TeammateVotingResult> {
        return startRequest( body: ["TeammateId": teammateID,
                                    "MyVote": risk ?? NSNull(),
                                    "Since": server.timestamp,
                                    "ProxyAvatarSize": Constant.proxyAvatarSize],
                             type: .teammateVote)
    }
    
    func createNewClaim(model: NewClaimModel) -> Future<ClaimEntityLarge> {
        let dateString = Formatter.teambrellaShortDashed.string(from: model.incidentDate)
        return startRequest(body: ["TeamId": model.teamID,
                                   "IncidentDate": dateString,
                                   "Expenses": model.expenses,
                                   "Message": model.text,
                                   "Images": model.images,
                                   "Address": model.address],
                            type: .newClaim)
    }
    
    func createNewChat(model: NewChatModel) -> Future<ChatModel> {
        return startRequest(body: ["TeamId": model.teamID,
                                   "Text": model.text,
                                   "Title": model.title],
                            type: .newChat)
    }
    
    func mute(topicID: String, isMuted: Bool) -> Future<Bool> {
        return startRequest( body: ["TopicId": topicID,
                                    "IsMuted": isMuted],
                             type: .mute)
    }
    
    func requestPrivateList(offset: Int, limit: Int, filter: String?) -> Future<[PrivateChatUser]> {
        var body: [String: Any] = ["Offset": offset,
                                   "Limit": limit]
        filter.map { body["Search"] = $0 }
        return startRequest(body: body, type: .privateList)
    }
    
    func requestSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity> {
        return startRequest(body: ["TeamId": teamID,
                                   "NewTeammatesNotification": current.rawValue],
                            type: .mySettings)
    }
    
    func sendSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity> {
        return startRequest( body: ["TeamId": teamID,
                                    "NewTeammatesNotification": current.rawValue],
                             type: .setMySettings)
    }
    
    func requestPin(topicID: String) -> Future<PinEntity> {
        return startRequest(body: ["TopicId": topicID], type: .pin)
    }
    
    func sendPin(topicID: String, pinType: PinType) -> Future<PinEntity> {
        return startRequest(body: ["TopicId": topicID, "MyPin": pinType.rawValue], type: .setPin)
    }
    
    func setPostLike(postID: String, myLike: Int) -> Future<Bool> {
        return startRequest(body: ["PostId": postID, "MyLike": myLike], type: .setMyLike)
    }

    func setPostMarked(postID: String, isMarked: Bool) -> Future<Bool> {
        return startRequest(body: ["PostId": postID, "Marked": isMarked], type: .setMarked)
    }

    func registerKey(facebookToken: String, signature: String, wallet: String) -> Future<Bool> {
        let payload: [String: String] = ["facebookToken": facebookToken,
                                         "sigOfPublicKey": signature,
                                         "a": wallet]
        return registerKey(payload: payload, type: .registerKey)
    }
    
    func registerKey(socialToken: String, signature: String, wallet: String) -> Future<Bool> {
        let payload: [String: String] = ["auth0Token": socialToken,
                                         "sigOfPublicKey": signature,
                                         "a": wallet]
        return registerKey(payload: payload, type: .registerKey)
    }
    
    func registerKey(payload: [String: Any], type: TeambrellaPostRequestType) -> Future<Bool> {
        let promise = Promise<Bool>()
        freshKey { key in
            let body = RequestBody(key: key, payload: payload)
            let request = TeambrellaRequest<String>(type: type,
                                                    body: body,
                                                    success: { box in
                                                        switch box.value?.lowercased() {
                                                        case "ok":
                                                            promise.resolve(with: true)
                                                        default:
                                                            promise.resolve(with: false)
                                                        }
                                                        
            }, failure: promise.reject)
            request.start(server: self.server)
        }
        return promise
    }
    
    func registerKey(signature: String, userData: UserApplicationData) -> Future<Bool> {
        guard var payload = userData.dictionary else {
            fatalError()
        }
        
        payload["sigOfPublicKey"] = signature
        return registerKey(payload: payload, type: .joinRregisterKey)
    }
    
    func freshKey(completion: @escaping (Key) -> Void) {
        if let time = lastKeyTime, Date().timeIntervalSince(time) < 60.0 * 5.0 {
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
    
    func getWelcome(teamID: Int?, inviteCode: String?) -> Future<WelcomeEntity> {
        let teamID = teamID.map { String($0) } ?? ""
        let inviteCode = inviteCode ?? ""
        return startRequest( body: ["teamId": teamID,
                                    "invite": inviteCode],
                             type: .welcome,
                             isKeyNeeded: false)
    }
    
    private func successHandler<Value>(promise: Promise<Value>) -> (ServerReplyBox<Value>) -> Void {
        return { box in
            guard let value = box.value else {
                fatalError()
            }
            
            promise.resolve(with: value)
        }
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
    
    private func standardRequest<Value>(promise: Promise<Value>,
                                        type: TeambrellaPostRequestType,
                                        body: RequestBody,
                                        parameters: [String: String]? = nil,
                                        suffix: String? = nil) -> TeambrellaRequest<Value> {
        var request = TeambrellaRequest<Value>(type: type,
                                               parameters: parameters,
                                               body: body,
                                               success: self.successHandler(promise: promise),
                                               failure: promise.reject)
        request.suffix = suffix
        return request
    }
    
    private func startRequest<Value: Decodable>(body: [String: Any],
                                                type: TeambrellaPostRequestType,
                                                suffix: String? = nil,
                                                parameters: [String: String]? = nil,
                                                isKeyNeeded: Bool = true,
                                                isErrorAutoManaged: Bool = true) -> Promise<Value> {
        let promise = Promise<Value>()
        if isKeyNeeded {
            freshKey { key in
                let body = RequestBody(key: key, payload: body)
                let request = self.standardRequest(promise: promise,
                                                   type: type,
                                                   body: body,
                                                   parameters: parameters,
                                                   suffix: suffix)
                request.start(server: self.server, isErrorAutoManaged: isErrorAutoManaged)
            }
        } else {
            let body = RequestBody(key: nil, payload: body)
            let request = standardRequest(promise: promise,
                                          type: type,
                                          body: body,
                                          parameters: parameters,
                                          suffix: suffix)
            request.start(server: server, isErrorAutoManaged: isErrorAutoManaged)
        }

        return promise
    }
    
}
