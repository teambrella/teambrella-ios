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
        let requestType: TeambrellaPostRequestType = demo ? .demoTeams : .teams
        startRequest(promise: promise, body: [:], type: requestType)
        return promise
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
        let promise = Promise<HomeModel>()
        startRequest(promise: promise, body: ["topicId": topicID], type: .feedDeleteCard)
        return promise
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
        let promise = Promise<CoverageForDate>()
        let dateString = Formatter.teambrellaShortDashed.string(from: date)
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "Date": dateString],
                     type: .coverageForDate)
        return promise
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
        let promise = Promise<[WalletTransactionsModel]>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "offset": offset,
                            "limit": limit,
                            "search": search],
                     type: .walletTransactions)
        return promise
    }
    
    private func successHandler<Value>(promise: Promise<Value>) -> (ServerReplyBox<Value>) -> Void {
        return { box in
            guard let value = box.value else {
                fatalError()
            }
            
            promise.resolve(with: value)
        }
    }
    
    // MARK: Proxy
    
    func requestMyProxiesList(teamID: Int, offset: Int, limit: Int) -> Future<[ProxyCellModel]> {
        let promise = Promise<[ProxyCellModel]>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "Offset": offset,
                            "Limit": limit],
                     type: .myProxies)
        return promise
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
        let promise = Promise<ProxyRatingEntity>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "Offset": offset,
                            "Limit": limit,
                            "Search": searchString ?? "",
                            "SortBy": sortBy.rawValue],
                     type: .proxyRatingList)
        return promise
    }
    
    func requestProxyFor(teamID: Int, offset: Int, limit: Int) -> Future<ProxyForEntity> {
        let promise = Promise<ProxyForEntity>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "Offset": offset,
                            "Limit": limit],
                     type: .proxyFor)
        return promise
    }
    
    // MARK: Claims
    
    func updateClaimVote(claimID: Int, vote: Float?, lastUpdated: Int64) -> Future<ClaimVoteUpdate> {
        let promise = Promise<ClaimVoteUpdate>()
        startRequest(promise: promise,
                     body: ["ClaimId": claimID,
                            "MyVote": vote ?? NSNull(),
                            "Since": lastUpdated,
                            "ProxyAvatarSize": Constant.proxyAvatarSize],
                     type: .claimVote)
        return promise
    }
    
    func requestClaimsList(teamID: Int, offset: Int, limit: Int, filterTeammateID: Int?) -> Future<[ClaimEntity]> {
        let promise = Promise<[ClaimEntity]>()
        var payload: [String: Any] = ["TeamId": service.session?.currentTeam?.teamID ?? 0,
                                      "Offset": offset,
                                      "Limit": limit,
                                      "AvatarSize": Constant.avatarSize]
        if let teammateID = filterTeammateID {
            payload["TeammateIdFilter"] = teammateID
        }
        startRequest(promise: promise, body: payload, type: .claimsList)
        return promise
    }
    
    func requestClaim(claimID: Int) -> Future<ClaimEntityLarge> {
        let promise = Promise<ClaimEntityLarge>()
        startRequest(promise: promise,
                     body: ["id": claimID,
                            "AvatarSize": Constant.avatarSize,
                            "ProxyAvatarSize": Constant.proxyAvatarSize],
                     type: .claim)
        return promise
    }
    
    func requestClaimTransactions(teamID: Int,
                                  claimID: Int,
                                  limit: Int,
                                  offset: Int) -> Future<[ClaimTransactionsModel]> {
        let promise = Promise<[ClaimTransactionsModel]>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "ClaimId": claimID,
                            "Limit": limit,
                            "Offset": offset],
                     type: .claimTransactions)
        return promise
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
        let promise = Promise<TeammateLarge>()
        startRequest(promise: promise,
                     body: [
                        "UserId": userID,
                        "TeamId": teamID,
                        "AfterVer": 0
            ], type: .teammate)
        return promise
    }
    
    func requestWithdrawTransactions(teamID: Int) -> Future<WithdrawChunk> {
        let promise = Promise<WithdrawChunk>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID],
                     type: .withdrawTransactions)
        return promise
    }
    
    func requestTeammateOthersVoted(teamID: Int, teammateID: Int) -> Future<VotersList> {
        let promise = Promise<VotersList>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "TeammateId": teammateID],
                     type: .teammateVotesList)
        return promise
    }
    
    func requestClaimOthersVoted(teamID: Int, claimID: Int) -> Future<VotersList> {
        let promise = Promise<VotersList>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "ClaimId": claimID],
                     type: .claimVotesList)
        return promise
    }
    
    func requestChat(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel> {
        let promise = Promise<ChatModel>()
        startRequest(promise: promise, body: body, type: type)
        return promise
    }
    
    func sendChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatEntity> {
        let promise = Promise<ChatEntity>()
        startRequest(promise: promise, body: body, type: type)
        return promise
    }
    
    func sendPrivateChatMessage(type: TeambrellaPostRequestType, body: [String: Any]) -> Future<ChatModel> {
        let promise = Promise<ChatModel>()
        startRequest(promise: promise, body: body, type: type)
        return promise
    }
    
    func withdraw(teamID: Int, amount: Double, address: EthereumAddress) -> Future<WithdrawChunk> {
        let promise = Promise<WithdrawChunk>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "Amount": amount,
                            "ToAddress": address.string],
                     type: .withdraw)
        return promise
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
    
    func sendRiskVote(teammateID: Int, risk: Double?) -> Future<TeammateVotingResult> {
        let promise = Promise<TeammateVotingResult>()
        startRequest(promise: promise,
                     body: ["TeammateId": teammateID,
                            "MyVote": risk ?? NSNull(),
                            "Since": server.timestamp,
                            "ProxyAvatarSize": Constant.proxyAvatarSize],
                     type: .teammateVote)
        return promise
    }
    
    func createNewClaim(model: NewClaimModel) -> Future<ClaimEntityLarge> {
        let promise = Promise<ClaimEntityLarge>()
        let dateString = Formatter.teambrellaShortDashed.string(from: model.incidentDate)
        startRequest(promise: promise,
                     body: ["TeamId": model.teamID,
                            "IncidentDate": dateString,
                            "Expenses": model.expenses,
                            "Message": model.text,
                            "Images": model.images,
                            "Address": model.address],
                     type: .newClaim)
        return promise
    }
    
    func createNewChat(model: NewChatModel) -> Future<ChatModel> {
        let promise = Promise<ChatModel>()
        startRequest(promise: promise,
                     body: ["TeamId": model.teamID,
                            "Text": model.text,
                            "Title": model.title],
                     type: .newChat)
        return promise
    }
    
    func mute(topicID: String, isMuted: Bool) -> Future<Bool> {
        let promise = Promise<Bool>()
        startRequest(promise: promise,
                     body: ["TopicId": topicID,
                            "IsMuted": isMuted],
                     type: .mute)
        return promise
    }
    
    func requestPrivateList(offset: Int, limit: Int, filter: String?) -> Future<[PrivateChatUser]> {
        let promise = Promise<[PrivateChatUser]>()
        var body: [String: Any] = ["Offset": offset,
                                   "Limit": limit]
        filter.map { body["Search"] = $0 }
        startRequest(promise: promise, body: body, type: .privateList)
        return promise
    }
    
    func requestSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity> {
        let promise = Promise<SettingsEntity>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "NewTeammatesNotification": current.rawValue],
                     type: .mySettings)
        return promise
    }
    
    func sendSettings(current: TeamNotificationsType, teamID: Int) -> Future<SettingsEntity> {
        let promise = Promise<SettingsEntity>()
        startRequest(promise: promise,
                     body: ["TeamId": teamID,
                            "NewTeammatesNotification": current.rawValue],
                     type: .setMySettings)
        return promise
    }
    
    func requestPin(topicID: String) -> Future<PinEntity> {
        let promise = Promise<PinEntity>()
        startRequest(promise: promise, body: ["TopicId": topicID], type: .pin)
        return promise
    }
    
    func sendPin(topicID: String, pinType: PinType) -> Future<PinEntity> {
        let promise = Promise<PinEntity>()
        startRequest(promise: promise, body: ["TopicId": topicID, "MyPin": pinType.rawValue], type: .setPin)
        return promise
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
        let promise = Promise<WelcomeEntity>()
        
        let teamID = teamID.map { String($0) } ?? ""
        let inviteCode = inviteCode ?? ""
        startRequest(promise: promise,
                     body: ["teamId": teamID,
                            "invite": inviteCode],
                     type: .welcome)
        return promise
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
                                        body: RequestBody) -> TeambrellaRequest<Value> {
        return TeambrellaRequest<Value>(type: type,
                                        body: body,
                                        success: self.successHandler(promise: promise),
                                        failure: promise.reject)
    }
    
    private func startRequest<Value: Decodable>(promise: Promise<Value>,
                                                body: [String: Any],
                                                type: TeambrellaPostRequestType) {
        freshKey { key in
            let body = RequestBody(key: key, payload: body)
            let request = self.standardRequest(promise: promise, type: type, body: body)
            request.start(server: self.server)
        }
    }
    
}
