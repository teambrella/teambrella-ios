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

final class UniversalChatDatasource {
    var onUpdate: ((_ backward: Bool, _ hasNewItems: Bool, _ isFirstLoad: Bool) -> Void)?
    var onMessageSend: (() -> Void)?
    var onLoadPrevious: ((Int) -> Void)?
    
    var limit                                       = 10
    var cloudWidth: CGFloat                         = 0
    var previousCount: Int                          = 0
    var teamAccessLevel: TeamAccessLevel            = TeamAccessLevel.full
    
    var notificationsType: MuteVC.NotificationsType { return .subscribed }
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
    
    private var chunks: [ChatChunk]                 = []
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
    private var claim: EnhancedClaimEntity?
    
    var topicID: String? { return claim?.topicID }
    
    var claimID: Int? {
        if let strategy = strategy as? ClaimChatStrategy {
            return strategy.claim.id
        }
        return nil
    }
    
    var chatHeader: String? {
        if let strategy = strategy as? ClaimChatStrategy {
            return strategy.claim.description
        } else if let strategy = strategy as? HomeChatStrategy {
            return strategy.card.chatTitle
        }
        return nil
    }
    
    var count: Int { return chunks.reduce(0) { $0 + $1.count } }
    
    var title: String { return strategy.title }
    
    var lastIndexPath: IndexPath? { return count >= 1 ? IndexPath(row: count - 1, section: 0) : nil }
    
    var currentTopCell: IndexPath? {
        guard let topCellDate = topCellDate else { return nil }
        
        let models = chunks.flatMap { $0.cellModels }
        for (idx, model) in models.enumerated() where model.date == topCellDate {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }
    
    var allImages: [String] {
        let models = chunks.flatMap { $0.cellModels }
        let textCellModels = models.flatMap { $0 as? ChatTextCellModel }
        let fragments = textCellModels.flatMap { $0.fragments }
        var images: [String] = []
        for fragment in fragments {
            switch fragment {
            case let .image(string, _):
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
    
    func mute(type: MuteVC.NotificationsType) {
        //do sth
    }
    
    func addContext(context: ChatContext, itemType: ItemType) {
        strategy = ChatStrategyFactory.strategy(with: context)
        hasPrevious = strategy.canLoadBackward
        cellModelBuilder.showRate = itemType == .claim || itemType == .teammate
    }
    
    func loadNext() {
        load(previous: false)
    }
    
    func loadPrevious() {
        backwardOffset -= limit
        load(previous: true)
    }
    
    func clear() {
        chunks.removeAll()
        forwardOffset = 0
        backwardOffset = 0
        postsCount = 0
        hasNext = true
    }
    
    var unsentStorage: UnsentMessagesStorage = UnsentMessagesStorage()
    
    func send(text: String, imageFragments: [ChatFragment]) {
        isLoading = true
        let id = UUID().uuidString.lowercased()
        let message = UnsentMessage(text: text, imageFragments: imageFragments, id: id)
        unsentStorage.newSending(message: message)
        
        let temporaryModel = cellModelBuilder.unsentModel(fragments: imageFragments + [ChatFragment.text(text)],
                                                          id: id)
        let chunk = ChatChunk(cellModels: [temporaryModel], type: .temporary)
        addChunk(chunk: chunk)
        let body = strategy.updatedMessageBody(body: RequestBody(key: service.server.key, payload: message.dictionary))
        
        let request = TeambrellaRequest(type: strategy.postType, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            me.hasNext = true
            me.isLoading = false
            me.unsentStorage.sent(message: message)
            me.onMessageSend?()
            me.process(response: response, isPrevious: false, isMyNewMessage: true)
            }, failure: { [weak self] error in
                self?.unsentStorage.failedToSend(message: message)
        })
        request.start()
    }
    
    subscript(indexPath: IndexPath) -> ChatCellModel {
        var idx = 0
        var rightChunk: ChatChunk?
        for chunk in chunks {
            if idx + chunk.count > indexPath.row {
                rightChunk = chunk
                break
            }
            idx += chunk.count
        }
        guard let chunk = rightChunk else { fatalError("Wrong indexing") }
        
        let offset = indexPath.row - idx
        return chunk.cellModels[offset]
    }
    
    // MARK: Private
    
    private func load(previous: Bool) {
        let canLoadMore = previous ? hasPrevious : hasNext
        guard isLoading == false, canLoadMore else { return }
        
        isLoading = true
        if previous {
            isLoadPreviousNeeded = false
            topCellDate = chunks.first?.firstTextMessage?.date
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
        let chunk = ChatChunk(cellModels: models, type: .messages)
        addChunk(chunk: chunk)
    }
    
    private func removeTemporaryChunksIfNeeded() {
        for (idx, chunk) in chunks.enumerated().reversed() {
            if chunk.type == .temporary {
                //postsCount -= 1
                chunks.remove(at: idx)
            } else if chunk.type == .messages {
                break
            }
        }
    }
    
    // CRUNCH: in most cases after sending the new message we receive 2 last messages back instead of one
    private func removeChatDuplicates(chat: [ChatEntity]) -> [ChatEntity] {
        guard let lastChunk = chunks.last else { return chat }
        
        var ids: Set<String> = []
        for cellModel in lastChunk.cellModels {
            if let cellModel = cellModel as? ChatTextCellModel {
                ids.insert(cellModel.entity.id)
            }
        }
        var chat = chat
        for (idx, item) in chat.enumerated().reversed() where ids.contains(item.id) {
            chat.remove(at: idx)
        }
        return chat
    }
    
    private func process(response: TeambrellaResponseType, isPrevious: Bool, isMyNewMessage: Bool) {
        removeTemporaryChunksIfNeeded()
        let count = self.count
        switch response {
        case let .chat(model):
            processCommonChat(model: model, isPrevious: isPrevious)
        case let .privateChat(messages):
            processPrivateChat(messages: messages, isPrevious: isPrevious, isMyNewMessage: isMyNewMessage)
            
        case let .newPost(post):
            let models = createCellModels(from: [post], isTemporary: true)
            let chunk = ChatChunk(cellModels: models, type: .temporary)
            addChunk(chunk: chunk)
            //postsCount += 1
            forwardOffset = 0
        default:
            return
        }
        let hasNewModels = self.count > count
        //handleNewSeparator(hasNewModels: hasNewModels, isPrevious: isPrevious, isMyNewMessage: isMyNewMessage)
        
        onUpdate?(isPrevious, hasNewModels, isFirstLoad)
        
        if  isFirstLoad && hasNewModels {
            isFirstLoad = false
        }
    }
    
    private func processCommonChat(model: ChatModel, isPrevious: Bool) {
        let filteredModel = removeChatDuplicates(chat: model.chat)
        addModels(models: filteredModel, isPrevious: isPrevious)
        claim?.update(with: model.basicPart)
        if model.chat.isEmpty {
            if isPrevious {
                hasPrevious = false
            } else {
                hasNext = false
                forwardOffset = 0
            }
        }
        lastRead = model.lastRead
        teamAccessLevel = model.teamAccessLevel
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
                //forwardOffset = 0
                //lastRead = model.lastRead + 1
            }
        }
    }
    
    private func addChunk(chunk: ChatChunk?) {
        guard let chunk = chunk else {
            isChunkAdded = false
            return
        }
        
        isChunkAdded = true
        for (idx, storedChunk) in chunks.enumerated() where chunk < storedChunk {
            chunks.insert(chunk, at: idx)
            return
        }
        chunks.append(chunk)
    }
    
    private func createCellModels(from entities: [ChatEntity], isTemporary: Bool) -> [ChatCellModel] {
        cellModelBuilder.font = font
        cellModelBuilder.width = cloudWidth - labelHorizontalInset * 2
        let models = cellModelBuilder.cellModels(from: entities,
                                                 lastChunk: chunks.last,
                                                 isClaim: strategy.requestType == .claimChat,
                                                 isTemporary: isTemporary)
        return models
    }
    
    private func handleNewSeparator(hasNewModels: Bool, isPrevious: Bool, isMyNewMessage: Bool) {
        if hasNewModels && isFirstLoad {
            addNewSeparatorIfNeeded(isPrevious: isPrevious, isMyNewMessage: isMyNewMessage)
            isFirstLoad = false
        } else if !hasNewModels {
            removeNewSeparatorIfNeeded()
        }
    }
    private func removeNewSeparatorIfNeeded() {
        if let firstChunk = chunks.first, firstChunk.cellModels.first is ChatNewMessagesSeparatorModel {
            chunks.removeFirst()
        }
    }
    
    private func addNewSeparatorIfNeeded(isPrevious: Bool, isMyNewMessage: Bool) {
        guard !isPrevious && !isMyNewMessage else { return }
        guard let firstChunk = chunks.first else { return }
        
        let minTime = firstChunk.minTime
        let model = ChatNewMessagesSeparatorModel(date: minTime.addingTimeInterval(-0.01))
        let chunk = ChatChunk(cellModels: [model], type: .technical)
        addChunk(chunk: chunk)
    }
    
}

struct UnsentMessage: Hashable {
    let text: String
    let imageFragments: [ChatFragment]
    var images: [String] {
        return imageFragments.flatMap {
            if case let .image(image, _) = $0 {
                return image
            } else {
                return nil
            }
        }
    }
    let id: String
    
    var dictionary: [String: Any] {
        return ["text": text,
                "NewPostId": id,
                "images": images]
    }
    
    var hashValue: Int { return text.hashValue ^ images.reduce(0) { $0 ^ $1.hashValue } ^ id.hashValue }
    
    static func == (lhs: UnsentMessage, rhs: UnsentMessage) -> Bool {
        return lhs.text == rhs.text && lhs.id == rhs.id && lhs.images == rhs.images
    }
    
}

class UnsentMessagesStorage {
    var sendingMessages: [UnsentMessage] = []
    var unsentMessages: [UnsentMessage] = []
    
    func newSending(message: UnsentMessage) {
        sendingMessages.append(message)
    }
    
    func failedToSend(message: UnsentMessage) {
        if let index = sendingMessages.index(of: message) {
            sendingMessages.remove(at: index)
        }
        unsentMessages.append(message)
    }
    
    func sent(message: UnsentMessage) {
        if let index = sendingMessages.index(of: message) {
            sendingMessages.remove(at: index)
        }
        if let index = unsentMessages.index(of: message) {
            unsentMessages.remove(at: index)
        }
    }
}
