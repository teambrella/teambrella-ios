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

class ServerDAO: DAO {
    struct Constant {
        static let recentSceneKey: String = "storage.recentScene"
    }
    
    var lastKeyTime: Date?
    var recentScene: SceneType {
        get {
            if let stored = UserDefaults.standard.object(forKey: Constant.recentSceneKey) as? String {
                return SceneType(rawValue: stored) ?? .home
            }
            return .home
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constant.recentSceneKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func requestTeams(demo: Bool) -> Future<TeamsModel> {
        let promise = Promise<TeamsModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: [:])
            let requestType: TeambrellaRequestType = demo ? .demoTeams : .teams
            let request = TeambrellaRequest(type: requestType,
                                            parameters: nil,
                                            body: body,
                                            success: { response in
                                                if case .teams(let teamsEntity) = response {
                                                    promise.resolve(with: teamsEntity)
                                                }
            }) { error in
                promise.reject(with: error)
            }
            request.start()
        }
        return promise
    }
    
    func requestHome(teamID: Int) -> Future<HomeScreenModel> {
        //let language = setLanguage()
        let promise = Promise<HomeScreenModel>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .home, body: body, success: { response in
                if case let .home(json) = response {
                    PlistStorage().store(json: json, for: .home, id: String(teamID))
                    let model = HomeScreenModel(json: json)
                    promise.resolve(with: model)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .home got \(response)"))
                }
            })
            request.start()
        }
        if let storedJSON = PlistStorage().retreiveJSON(for: .home, id: String(teamID)) {
            defer {
                promise.temporaryResolve(with: HomeScreenModel(json: storedJSON))
            }
        }
        return promise
    }
    
    func setLanguage() -> Future<String> {
        let promise = Promise<String>()
        freshKey { key in
            let body = RequestBody(key: key)
            let requestType: TeambrellaRequestType
            if let locale = Locale.current.languageCode, locale == "es" {
                requestType = .setLanguageEs
            } else {
                requestType = .setLanguageEn
            }
            let request = TeambrellaRequest(type: requestType,
                                            body: body,
                                            success: { response in
                                                if case let .setLanguage(language) = response {
                                                    log("Language is set to \(language)", type: .serviceInfo)
                                                    promise.resolve(with: language)
                                                } else {
                                                    let errorMessage = "Was waiting .setLanguage got \(response)"
                                                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                                                         description: errorMessage))
                                                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func deleteCard(topicID: String) -> Future<HomeScreenModel> {
        let promise = Promise<HomeScreenModel>()
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
            request.start()
        }
        return promise
    }
    
    func requestTeamFeed(context: FeedRequestContext) -> Future<[FeedEntity]> {
        let promise = Promise<[FeedEntity]>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["teamid": context.teamID,
                                                      "since": context.since,
                                                      "offset": context.offset,
                                                      "limit": context.limit,
                                                      "commentAvatarSize": 32,
                                                      "search": NSNull()])
            let request = TeambrellaRequest(type: .teamFeed, body: body, success: { response in
                if case .teamFeed(let json) = response {
                    PlistStorage().store(json: json, for: .teamFeed, id: "")
                    let feed = json.arrayValue.flatMap { FeedEntity(json: $0) }
                    promise.resolve(with: feed)
                } else {
                    promise.reject(with: TeambrellaError(kind: .wrongReply,
                                                         description: "Was waiting .teamFeed, got \(response)"))
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        if let storedJSON = PlistStorage().retreiveJSON(for: .teamFeed, id: "") {
            defer {
                let feed = storedJSON.arrayValue.flatMap { FeedEntity(json: $0) }
                promise.temporaryResolve(with: feed)
            }
        }
        return promise
    }
    
    func requestCoverage(for date: Date, teamID: Int) -> Future<(coverage: Double, limit: Double)> {
        let promise = Promise<(coverage: Double, limit: Double)>()
        let dateString = Formatter.teambrellaShortDashed.string(from: date)
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID,
                                                       "Date": dateString])
            let request = TeambrellaRequest(type: .coverageForDate, body: body, success: { response in
                if case .coverageForDate(let coverage, let limit) = response {
                    promise.resolve(with: (coverage: coverage, limit: limit))
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func requestWallet(teamID: Int) -> Future<WalletEntity> {
        let promise = Promise<WalletEntity>()
        freshKey { key in
            let body = RequestBody(key: key, payload: ["TeamId": teamID])
            let request = TeambrellaRequest(type: .wallet, body: body, success: { response in
                if case .wallet(let wallet) = response {
                 promise.resolve(with: wallet)
                }
                }, failure: { [weak self] error in
                   promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func requestProxyRating(teamID: Int,
                            offset: Int,
                            limit: Int,
                            searchString: String?,
                            sortBy: SortVC.SortType) -> Future<UserIndexCellModel> {
        let promise = Promise<UserIndexCellModel>()
        freshKey { key in
            
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
            request.start()
        }
        return promise
    }
    
    func sendPhoto(data: Data) -> Future<String> {
        let promise = Promise<String>()
        freshKey { key in
            var body = RequestBody(key: service.server.key, payload: nil)
            body.contentType = "image/jpeg"
            body.data = data
            let request = TeambrellaRequest(type: .uploadPhoto, body: body, success: { response in
                if case .uploadPhoto(let name) = response {
                    promise.resolve(with: name)
                }
            }, failure: { error in
                promise.reject(with: error)
            })
            request.start()
        }
        return promise
    }
    
    func createNewClaim(model: NewClaimModel) -> Future<EnhancedClaimEntity> {
        let promise = Promise<EnhancedClaimEntity>()
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
            request.start()
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
            request.start()
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
            request.start()
        }
        return promise
    }
    
    func freshKey(completion: @escaping (Key) -> Void) {
        if let time = lastKeyTime, Date().timeIntervalSince(time) < 60 * 10 {
            completion(service.server.key)
        } else {
            service.server.updateTimestamp(completion: { _, _ in
                defer { self.lastKeyTime = Date() }
                completion(service.server.key)
            })
        }
    }
}
