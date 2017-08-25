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
    var cellModels: [ChatCellModel] = []
    var count: Int { return cellModels.count }
    
    var limit                         = 10
    var since: Int64                  = 0
    var offset: Int { return posts.count }
    var backwardOffset: Int = 0
    var avatarSize                    = 64
    var commentAvatarSize             = 32
    var cloudWidth: CGFloat           = 0
    var labelHorizontalInset: CGFloat = 8
    var font: UIFont                  = UIFont.teambrella(size: 14)
    
    private(set) var isLoading = false
    private(set) var hasNext = true
    private(set) var hasPrevious = true
    var title: String { return strategy.title }
    var lastIndexPath: IndexPath { return IndexPath(row: count - 1, section: 0) }
    var previousCount: Int = 0
    
    var isLoadNextNeeded: Bool = false {
        didSet {
            if !isLoading && hasNext {
                loadNext()
            }
        }
    }
    
    var isLoadPreviousNeeded: Bool = false {
        didSet {
            if !isLoading && hasPrevious {
                loadPrevious()
            }
        }
    }
    
    private var strategy: ChatDatasourceStrategy = EmptyChatStrategy()
    
    var onUpdate: ((Bool) -> Void)?
    var onMessageSend: (() -> Void)?
    
    let cellModelBuilder = ChatModelBuilder()
    
    func addContext(context: ChatContext) {
        strategy = ChatStrategyFactory.strategy(with: context)
    }
    
    func loadNext() {
        guard isLoading == false, hasNext == true else { return }
        
        isLoading = true
        isLoadNextNeeded = false
        let key = service.server.key
        
        let body = strategy.updatedChatBody(body: RequestBody(key: key,
                                                              payload: ["since": since,
                                                                        "limit": limit,
                                                                        "offset": offset,
                                                                        "avatarSize": avatarSize,
                                                                        "commentAvatarSize": commentAvatarSize]))
        let request = TeambrellaRequest(type: strategy.requestType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.process(response: response, isPrevious: false)
            me.isLoading = false
        })
        request.start()
    }
    
    func loadPrevious() {
        guard isLoading == false, hasPrevious == true else { return }
        
        isLoading = true
        isLoadPreviousNeeded = false
        let key = service.server.key
        
        let body = strategy.updatedChatBody(body: RequestBody(key: key,
                                                              payload: ["since": since,
                                                                        "limit": -limit,
                                                                        "offset": backwardOffset,
                                                                        "avatarSize": avatarSize,
                                                                        "commentAvatarSize": commentAvatarSize]))
        let request = TeambrellaRequest(type: strategy.requestType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.process(response: response, isPrevious: true)
            me.isLoading = false
        })
        request.start()
    }
    
    func send(text: String, images: [String]) {
        isLoading = true
        let body = strategy.updatedMessageBody(body: RequestBody(key: service.server.key, payload: ["text": text,
                                                                                                    "images": images]))
        
        let request = TeambrellaRequest(type: .newPost, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.hasNext = true
            me.isLoading = false
            me.onMessageSend?()
            me.process(response: response, isPrevious: false)
        })
        request.start()
    }
    
    private func process(response: TeambrellaResponseType, isPrevious: Bool) {
        switch response {
        case let .chat(model):
            previousCount = posts.count
            if isPrevious {
                posts.insert(contentsOf: model.chat, at: 0)
                backwardOffset += model.chat.count
            } else {
                posts.append(contentsOf: model.chat)
            }
            createCellModels(from: model.chat, isPrevious: isPrevious)
            claim?.update(with: model.basicPart)
            since = model.lastRead
            if limit > model.chat.count {
                if isPrevious {
                    hasPrevious = false
                } else {
                    hasNext = false
                }
            }
        case let .newPost(post):
            posts.append(post)
            createCellModels(from: [post], isPrevious: false)
        default:
            return
        }
        onUpdate?(isPrevious)
    }
    
    private func createCellModels(from entities: [ChatEntity], isPrevious: Bool) {
        let models = cellModelBuilder.cellModels(from: entities,
                                                 width: cloudWidth - labelHorizontalInset * 2,
                                                 font: font)
        if isPrevious {
            cellModels.insert(contentsOf: models, at: 0)
        } else {
            cellModels.append(contentsOf: models)
        }
    }
    
    subscript(indexPath: IndexPath) -> ChatCellModel {
        if indexPath.row > posts.count - limit / 2 {
            isLoadNextNeeded = true
        }
        if indexPath.row == 0 {
            isLoadPreviousNeeded = true
        }
        return cellModels[indexPath.row]
    }
}
