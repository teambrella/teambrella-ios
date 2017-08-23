//
//  UniversalChatDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.

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

class UniversalChatDatasource {
    private var topic: Topic?
    
    private var claim: EnhancedClaimEntity?
    var name: String? {
        didSet {
            
        }
    }
    
    var posts: [ChatEntity] = []
    var limit = 100
    var since: Int64 = 0
    var offset = 0
    var avatarSize = 64
    var commentAvatarSize = 32
    private(set) var isLoading = false
    private(set) var hasMore = true
    var title: String { return strategy.title }
    
    private var strategy: ChatDatasourceStrategy = EmptyChatStrategy()
    
    var onUpdate: (() -> Void)?
    
    var count: Int { return posts.count }
    
    func addContext(context: ChatContext) {
        strategy = ChatStrategyFactory.strategy(with: context)
    }
    
    func loadNext() {
        guard isLoading == false, hasMore == true else { return }
        
        isLoading = true
        let key = service.server.key
        
        let body = strategy.updatedChatBody(body: RequestBody(key: key,
                                                              payload: ["since": since,
                                                                        "limit": limit,
                                                                        "offset": offset,
                                                                        "avatarSize": avatarSize,
                                                                        "commentAvatarSize": commentAvatarSize]))
        let request = TeambrellaRequest(type: strategy.requestType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.process(response: response)
            me.isLoading = false
        })
        request.start()
    }
    
    func send(text: String, images: [String], completion: @escaping (Bool) -> Void) {
        let body = strategy.updatedMessageBody(body: RequestBody(key: service.server.key, payload: ["text": text,
                                                                                                    "images": images]))
        
        let request = TeambrellaRequest(type: .newPost, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            if case .newPost(let post) = response {
                me.posts.append(post)
                completion(true)
            } else {
                completion(false)
            }
            me.hasMore = true
        })
        request.start()
    }
    
    func createChat(teamID: Int, title: String, text: String) {
        guard isLoading == false else { return }
        
        isLoading = true
        let body = RequestBody(key: service.server.key, payload: ["TeamId": teamID,
                                                                  "Title": title,
                                                                  "Text": text])
        let request = TeambrellaRequest(type: strategy.createChatType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
           me.process(response: response)
            me.isLoading = false
        })
        request.start()
    }
    
    private func process(response: TeambrellaResponseType) {
        if case let .chat(model) = response {
            posts.append(contentsOf: model.chat)
            claim?.update(with: model.basicPart)
            //claim?.update(with: teamPart)
            since = model.lastRead
            offset += model.chat.count
            onUpdate?()
            if limit > model.chat.count {
                hasMore = false
            }
        }
    }
    
}
