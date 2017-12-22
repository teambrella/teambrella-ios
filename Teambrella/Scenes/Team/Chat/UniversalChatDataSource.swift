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

enum UniversalChatType {
    case privateChat, application, claim, discussion
}

final class UniversalChatDatasource {
    var onUpdate: ((_ backward: Bool, _ hasNewItems: Bool, _ isFirstLoad: Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onSendMessage: ((IndexPath) -> Void)?
    var onLoadPrevious: ((Int) -> Void)?
    
    var limit                                       = 10
    var cloudWidth: CGFloat                         = 0
    var previousCount: Int                          = 0
    var teamAccessLevel: TeamAccessLevel            = TeamAccessLevel.full
    
    var notificationsType: TopicMuteType = .unknown
    var hasNext                                     = true
    var hasPrevious                                 = true
    var isFirstLoad                                 = true
    var isLoadNextNeeded: Bool                      = false {
        didSet {
            if isLoadNextNeeded && !isLoading && hasNext {
                loadNext()
            }
        }
    }
    
    var name: String?
    
    var chatModel: ChatModel? {
        didSet {
            notificationsType = TopicMuteType.type(from: chatModel?.isMuted)
            cellModelBuilder.showRate = chatType == .application || chatType == .claim
        }
    }
    
    private var models: [ChatCellModel]             = []
    private var lastInsertionIndex                  = 0
    
    // private var chunks: [ChatChunk]                 = []
    private var strategy: ChatDatasourceStrategy    = EmptyChatStrategy()
    private var cellModelBuilder                    = ChatModelBuilder()
    
    private var lastRead: Int64                     = 0
    private var forwardOffset: Int                  = 0
    private var backwardOffset: Int                 = 0
    private var postsCount: Int                     = 0
    private var avatarSize                          = 64
    private var commentAvatarSize                   = 32
    private var labelHorizontalInset: CGFloat       = 8
    private var font: UIFont                        = UIFont.teambrella(size: 14)
    
    private(set) var isLoading                      = false
    private var isChunkAdded                        = false
    
    private var topCellDate: Date?
    private var topic: Topic?
    
    var claim: EnhancedClaimEntity? {
        if let strategy = strategy as? ClaimChatStrategy {
            return strategy.claim
        }
        return nil
    }
    
    var claimID: Int? {
        if let claim = claim {
            return claim.id
        }
        return nil
    }
    
    var teammateInfo: TeammateBasicInfo? {
        if let strategy = strategy as? TeammateChatStrategy {
            return strategy.teammate.basic
        }
        return nil
    }
    
    var topicID: String? { return claim?.topicID }
    
    var chatHeader: String? {
        if let strategy = strategy as? ClaimChatStrategy {
            return strategy.claim.description
        } else if let strategy = strategy as? HomeChatStrategy {
            return strategy.card.chatTitle
        }
        return nil
    }
    
    var count: Int { return models.count }
    
    var title: String {
        if strategy is PrivateChatStrategy {
            return strategy.title
        }
        
        guard let chatModel = chatModel else {
            return ""//strategy.title
        }
        
        if chatModel.basicPart is BasicPartClaimConcrete {
            return "Team.Chat.TypeLabel.claim".localized.lowercased().capitalized + " \(chatModel.id)"
        } else if chatModel.basicPart is BasicPartTeammateConcrete {
            return "Team.Chat.TypeLabel.application".localized.lowercased().capitalized
        } else if let basicPart = chatModel.basicPart as? BasicPartDiscussionConcrete {
            return basicPart.title
        } else {
            return strategy.title
        }
    }
    
    var chatType: UniversalChatType {
        switch strategy {
        case is PrivateChatStrategy:
            return .privateChat
        case is ClaimChatStrategy:
            return .claim
        case is TeammateChatStrategy:
            return .application
        default:
            break
        }
        
        if let chatModel = chatModel {
            switch chatModel.basicPart {
            case is BasicPartClaimConcrete:
                return .claim
            case is BasicPartTeammateConcrete:
                return .application
            case is BasicPartDiscussionConcrete:
                return .discussion
            default:
                break
            }
        }
        
        return .discussion
    }
    
    var isObjectViewNeeded: Bool {
        switch chatType {
        case .application, .claim:
            return true
        default:
            return false
        }
    }
    
    var lastIndexPath: IndexPath? { return count >= 1 ? IndexPath(row: count - 1, section: 0) : nil }
    
    var currentTopCellPath: IndexPath? {
        guard let topCellDate = topCellDate else { return nil }
        
        for (idx, model) in models.enumerated() where model.date == topCellDate {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }
    
    var allImages: [String] {
        let textCellModels = models.flatMap { $0 as? ChatTextCellModel }
        let fragments = textCellModels.flatMap { $0.fragments }
        var images: [String] = []
        for fragment in fragments {
            switch fragment {
            case let .image(string, _, _):
                images.append(string)
            default:
                break
            }
        }
        return images
    }
    
    var isLoadPreviousNeeded: Bool = false {
        didSet {
            if isLoadPreviousNeeded && !isLoading && hasPrevious {
                loadPrevious()
            }
        }
    }
    
    var isPrivateChat: Bool { return strategy is PrivateChatStrategy }
    
    func mute(type: TopicMuteType, completion: @escaping (Bool) -> Void) {
        guard let topicID = chatModel?.topicID else { return }
        
        let isMuted = type == .muted
        service.dao.mute(topicID: topicID, isMuted: isMuted).observe { [weak self] result in
            switch result {
            case let .value(muted):
                self?.notificationsType = TopicMuteType.type(from: muted)
                completion(muted)
            case let .error(error):
                log("\(error)", type: [.error, .serverReply])
            default:
                break
            }
        }
    }
    
    func addContext(context: ChatContext, itemType: ItemType) {
        strategy = ChatStrategyFactory.strategy(with: context)
        hasPrevious = strategy.canLoadBackward
        cellModelBuilder.showRate = chatType == .application || chatType == .claim
    }
    
    func loadNext() {
        load(previous: false)
    }
    
    func loadPrevious() {
        backwardOffset -= limit
        load(previous: true)
    }
    
    func clear() {
        models.removeAll()
        forwardOffset = 0
        backwardOffset = 0
        postsCount = 0
        hasNext = true
    }
    
    func send(text: String, imageFragments: [ChatFragment]) {
        isLoading = true
        let id = UUID().uuidString.lowercased()
        //let temporaryModel = cellModelBuilder.unsentModel(fragments: imageFragments + [ChatFragment.text(text)],
        //                                                 id: id)
        //addCellModel(model: temporaryModel)
        let images = imageFragments.flatMap {
            if case let .image(image, _, _) = $0 {
                return image
            } else {
                return nil
            }
        }
        let body = strategy.updatedMessageBody(body: RequestBody(key: service.server.key, payload: ["Text": text,
                                                                                                    "NewPostId": id,
                                                                                                    "Images": images]))
        let request = TeambrellaRequest(type: strategy.postType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.hasNext = true
            me.isLoading = false
            me.process(response: response, isPrevious: false, isMyNewMessage: true)
            }, failure: { [weak self] error in
                self?.onError?(error)
        })
        request.start()
    }
    
    subscript(indexPath: IndexPath) -> ChatCellModel {
        guard indexPath.row < models.count else {
            fatalError("Wrong index: \(indexPath), while have only \(models.count) models")
        }
        
        return models[indexPath.row]
    }
    
    // MARK: Private
    
    private func load(previous: Bool) {
        let canLoadMore = previous ? hasPrevious : hasNext
        guard isLoading == false, canLoadMore else { return }
        
        isLoading = true
        if previous {
            isLoadPreviousNeeded = false
            topCellDate = models.first?.date
        } else {
            isLoadNextNeeded = false
        }
        
        service.dao.freshKey { [weak self] key in
            guard let me = self else { return }
            
            let limit = me.limit// previous ? -me.limit: me.limit
            let offset = previous ? me.backwardOffset : me.forwardOffset
            var payload: [String: Any] = ["limit": limit,
                                          "offset": offset,
                                          "avatarSize": me.avatarSize,
                                          "commentAvatarSize": me.commentAvatarSize]
            if me.lastRead > 0 {
                payload["since"] = me.lastRead
            }
            let body = me.strategy.updatedChatBody(body: RequestBody(key: key, payload: payload))
            let request = TeambrellaRequest(type: me.strategy.requestType,
                                            body: body,
                                            success: { [weak me] response in
                                                guard let me = me else { return }
                                                
                                                me.isLoading = false
                                                me.process(response: response,
                                                           isPrevious: previous,
                                                           isMyNewMessage: false)
            })
            request.start()
        }
    }
    
    private func addCellModels(models: [ChatCellModel]) {
        models.forEach { self.addCellModel(model: $0) }
    }
    
    private func addCellModel(model: ChatCellModel) {
        guard !models.isEmpty else {
            models.append(model)
            return
        }
        
        while lastInsertionIndex > 0 && models[lastInsertionIndex].date > model.date {
            lastInsertionIndex -= 1
        }
        while lastInsertionIndex < models.count && models[lastInsertionIndex].date <= model.date {
            lastInsertionIndex += 1
        }
        
        let previous = lastInsertionIndex > 0 ? models[lastInsertionIndex - 1] : nil
        let next = lastInsertionIndex < models.count ? models[lastInsertionIndex] : nil
        if let previous = previous, previous.id == model.id {
            models[lastInsertionIndex - 1] = model
        } else if let next = next, next.id == model.id {
            models[lastInsertionIndex] = model
        } else if lastInsertionIndex < models.count {
            models.insert(model, at: lastInsertionIndex)
        } else {
            models.append(model)
        }
        //removeTemporaryIfNeeded()
        addSeparatorIfNeeded()
    }
    
    private func removeTemporaryIfNeeded() {
        guard lastInsertionIndex > 0 else { return }
        
        let previous = models[lastInsertionIndex - 1]
        guard previous.isTemporary else { return }
        
        let current = models[lastInsertionIndex]
        if current.id == previous.id {
            models.remove(at: lastInsertionIndex - 1)
            lastInsertionIndex -= 1
        }
    }
    
    private func addSeparatorIfNeeded() {
        guard lastInsertionIndex > 0 && lastInsertionIndex < models.count else { return }
        
        let previous = models[lastInsertionIndex - 1]
        let current = models[lastInsertionIndex]
        if let separator = cellModelBuilder.separatorModelIfNeeded(firstModel: previous, secondModel: current) {
            models.insert(separator, at: lastInsertionIndex)
            lastInsertionIndex += 1
        }
    }
    
    private func addModels(models: [ChatEntity], isPrevious: Bool) {
        previousCount = postsCount
        let currentPostsCount = models.count
        postsCount += currentPostsCount
        if isPrevious {
            isLoadPreviousNeeded = false
        } else {
            isLoadNextNeeded = false
            forwardOffset += currentPostsCount
        }
        
        let models = createCellModels(from: models, isTemporary: false)
        addCellModels(models: models)
    }
    
    private func process(response: TeambrellaResponseType, isPrevious: Bool, isMyNewMessage: Bool) {
        let count = self.count
        switch response {
        case let .chat(model):
            processCommonChat(model: model, isPrevious: isPrevious)
        case let .privateChat(messages):
            processPrivateChat(messages: messages, isPrevious: isPrevious, isMyNewMessage: isMyNewMessage)
            
        case let .newPost(post):
            let models = createCellModels(from: [post], isTemporary: true)
            addCellModels(models: models)
            postsCount += 1
            forwardOffset = 0
        default:
            return
        }
        let hasNewModels = self.count > count
        if isMyNewMessage {
            onSendMessage?(IndexPath(row: lastInsertionIndex, section: 0))
        } else {
        onUpdate?(isPrevious, hasNewModels, isFirstLoad)
        }
        isFirstLoad = false
//        if  isFirstLoad && hasNewModels {
//            isFirstLoad = false
//        }
    }
    
    private func processCommonChat(model: ChatModel, isPrevious: Bool) {
        addModels(models: model.chat, isPrevious: isPrevious)
        chatModel = model
        if model.chat.isEmpty {
            if isPrevious {
                hasPrevious = false
            } else {
                hasNext = false
                forwardOffset = 0
            }
        }
        lastRead = model.lastRead
        teamAccessLevel = model.teamPart?.accessLevel ?? .noAccess
    }
    
    private func processPrivateChat(messages: [ChatEntity], isPrevious: Bool, isMyNewMessage: Bool) {
        if isMyNewMessage {
            clear()
        }
        addModels(models: messages, isPrevious: isPrevious)
        if messages.isEmpty {
            if isPrevious {
                hasPrevious = false
            } else {
                hasNext = false
            }
        }
    }
    
    private func createCellModels(from entities: [ChatEntity], isTemporary: Bool) -> [ChatCellModel] {
        cellModelBuilder.font = font
        cellModelBuilder.width = cloudWidth - labelHorizontalInset * 2
        let models = cellModelBuilder.cellModels(from: entities,
                                                 isClaim: strategy.requestType == .claimChat,
                                                 isTemporary: isTemporary)
        return models
    }
    
}
