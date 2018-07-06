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

enum UniversalChatType {
    case privateChat, application, claim, discussion

    static func with(itemType: ItemType) -> UniversalChatType {
        switch itemType {
        case .claim:
            return .claim
        case .privateChat:
            return .privateChat
        case .teammate:
            return .application
        default:
            return .discussion
        }
    }
}

final class UniversalChatDatasource {
    enum Constant {
        static let limit = 30
        static let firstLoadPreviousMessagesCount = 10
    }

    var onUpdate: ((_ backward: Bool, _ hasNewItems: Bool, _ isFirstLoad: Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onSendMessage: ((IndexPath) -> Void)?
    var onLoadPrevious: ((Int) -> Void)?
    var onClaimVoteUpdate: (() -> Void)?

    var cloudWidth: CGFloat                         = 0
    var previousCount: Int                          = 0
    var teamAccessLevel: TeamAccessLevel            = TeamAccessLevel.full
    
    var notificationsType: TopicMuteType            = .unknown
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
            notificationsType = TopicMuteType.type(from: chatModel?.discussion.isMuted)
            cellModelBuilder.showRate = chatType == .application || chatType == .claim
        }
    }
    
    private var models: [ChatCellModel]             = []
    private var lastInsertionIndex                  = 0
    
    private var strategy: ChatDatasourceStrategy    = EmptyChatStrategy()
    var cellModelBuilder                            = ChatModelBuilder()
    
    private var lastRead: UInt64 { return chatModel?.discussion.lastRead ?? 0 }
    private var forwardOffset: Int                  = 0
    private var backwardOffset: Int                 = 0
    private var postsCount: Int                     = 0
    private var avatarSize                          = 64
    private var commentAvatarSize                   = 32
    private var labelHorizontalInset: CGFloat       = 8
    private var font: UIFont                        = UIFont.teambrella(size: 14)
    
    private(set) var isLoading                      = false
    private var isChunkAdded                        = false
    private var hasNewMessagesSeparator: Bool       = false
    private var isClaimPaidModelAdded               = false
    
    private var topCellDate: Date?
    
    var myVote: Double? {
        return chatModel?.voting?.myVote
    }

    var claimDate: Date? {
        return chatModel?.basic?.incidentDate
    }

    var topicID: String? { return chatModel?.discussion.topicID }
    
    var count: Int { return models.count }

    var dao: DAO { return service.dao }
    
    var title: String {
        guard !(strategy is PrivateChatStrategy) else { return strategy.title }
        guard let chatModel = chatModel else { return "" }
        
        if chatModel.isClaimChat {
            if let date = claimDate {
                return "Team.Chat.TypeLabel.claim".localized.lowercased().capitalized + " - " +
                    Formatter.teambrellaShort.string(from: date)
            } else {
                return "Team.Chat.TypeLabel.claim".localized.lowercased().capitalized
            }
        } else if chatModel.isApplicationChat {
            return "Team.Chat.TypeLabel.application".localized.lowercased().capitalized
        } else if let title = chatModel.basic?.title {
            return title
        } else {
            return ""
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
        case let strategy as FeedChatStrategy:
            let type = strategy.feedEntity.itemType
            return UniversalChatType.with(itemType: type)
        default:
            break
        }

        if chatModel?.basic?.claimAmount != nil { return .claim }
        if chatModel?.basic?.title != nil { return .discussion }
        if chatModel?.basic?.userID != nil { return .application }
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

    var lastReadIndexPath: IndexPath? {
        guard lastRead != 0 else { return lastIndexPath }

        let lastReadDate = Date(ticks: lastRead)
        for (idx, model) in models.enumerated() where model.date >= lastReadDate {
            return IndexPath(row: idx, section: 0)
        }
        return lastIndexPath
    }
    
    var allImages: [String] {
        let textCellModels = models.compactMap { $0 as? ChatCellUserDataLike }
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
        guard let topicID = chatModel?.discussion.topicID else { return }
        
        let isMuted = type == .muted
        dao.mute(topicID: topicID, isMuted: isMuted).observe { [weak self] result in
            switch result {
            case let .value(muted):
                self?.notificationsType = TopicMuteType.type(from: muted)
                completion(muted)
            case let .error(error):
                log("\(error)", type: [.error, .serverReply])
            }
        }
    }
    
    func addContext(context: ChatContext, itemType: ItemType) {
        strategy = ChatStrategyFactory.strategy(with: context)
        hasPrevious = strategy.canLoadBackward
        cellModelBuilder.showRate = chatType == .application || chatType == .claim
        cellModelBuilder.showTheirAvatar = chatType != .privateChat
    }
    
    func loadNext() {
        load(previous: false)
    }
    
    func loadPrevious() {
        backwardOffset -= Constant.limit
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
        let images: [String] = imageFragments.compactMap {
            if case let .image(image, _, _) = $0 {
                return image
            } else {
                return nil
            }
        }

        dao.freshKey { [weak self] key in
            guard let `self` = self else { return }
            
            let body = self.strategy.updatedMessageBody(body: RequestBody(key: key, payload: ["Text": text,
                                                                                              "NewPostId": id,
                                                                                              "Images": images]))
            let request = TeambrellaRequest(type: self.strategy.postType, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                self.hasNext = true
                self.isLoading = false
                self.process(response: response, isPrevious: false, isMyNewMessage: true)
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            self.dao.performRequest(request: request)
        }
    }
    
    func updateVoteOnServer(vote: Float?) {
        guard let claimID = chatModel?.id else { return }

        let lastUpdated = chatModel?.lastUpdated ?? 0
        service.dao.updateClaimVote(claimID: claimID,
                                    vote: vote,
                                    lastUpdated: lastUpdated)
            .observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .value(voteUpdate):
                    self.chatModel?.update(with: voteUpdate)
                    self.onClaimVoteUpdate?()
                    log("Updated claim with \(voteUpdate)", type: .info)
                case let .error(error):
                    self.onError?(error)
                }
        }
    }

    subscript(indexPath: IndexPath) -> ChatCellModel {
        guard indexPath.row < models.count else {
            fatalError("Wrong index: \(indexPath), while have only \(models.count) models")
        }
        
        return models[indexPath.row]
    }
}

// MARK: Private
extension UniversalChatDatasource {
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
        
        dao.freshKey { [weak self] key in
            guard let `self` = self else { return }
            
            var limit = Constant.limit

            var offset = previous
                ? self.backwardOffset
                : self.forwardOffset

            if self.isFirstLoad {
                limit += Constant.firstLoadPreviousMessagesCount
                offset -= Constant.firstLoadPreviousMessagesCount
            }
            var payload: [String: Any] = ["limit": limit,
                                          "offset": offset,
                                          "avatarSize": self.avatarSize,
                                          "commentAvatarSize": self.commentAvatarSize]
            if self.lastRead > 0 {
                payload["since"] = self.lastRead
            }
            let body = self.strategy.updatedChatBody(body: RequestBody(key: key, payload: payload))
            let request = TeambrellaRequest(type: self.strategy.requestType,
                                            body: body,
                                            success: { [weak self] response in
                                                guard let`self` = self else { return }
                                                
                                                self.isLoading = false
                                                self.process(response: response,
                                                             isPrevious: previous,
                                                             isMyNewMessage: false)
            })
            self.dao.performRequest(request: request)
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

        // find the place in array where to insert new item
        if !models.isEmpty && lastInsertionIndex >= models.count {
            lastInsertionIndex = models.count - 1
        }

        while lastInsertionIndex > 0
            && models[lastInsertionIndex].date > model.date {
                lastInsertionIndex -= 1
        }
        while lastInsertionIndex < models.count
            && models[lastInsertionIndex].date <= model.date {
                lastInsertionIndex += 1
        }

        // insert new item in the array
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
    
    private func addModels(models: [ChatEntity], isPrevious: Bool, chatModel: ChatModel?) {
        previousCount = postsCount
        let currentPostsCount = models.count
        postsCount += currentPostsCount
        if isPrevious {
            isLoadPreviousNeeded = false
        } else {
            isLoadNextNeeded = false
            forwardOffset += currentPostsCount
            if lastRead == 0,
                let last = models.last,
                let chatModel = chatModel,
                last.lastUpdated > chatModel.discussion.lastRead {
                insertNewMessagesSeparator(lastRead: chatModel.discussion.lastRead)
            }
        }
        
        let models = createCellModels(from: models, isTemporary: false)
        addCellModels(models: models)
    }
    
    private func insertNewMessagesSeparator(lastRead: UInt64) {
        guard isFirstLoad else { return }
        guard lastRead != 0 else { return }

        _ = removeNewMessagesSeparator()
        let lastReadDate = Date(ticks: lastRead)
        let separatorDate = lastReadDate.addingTimeInterval(0.1)
        let model = ChatNewMessagesSeparatorModel(date: separatorDate)
        addCellModels(models: [model])
        hasNewMessagesSeparator = true
    }
    
   func removeNewMessagesSeparator() -> Bool {
        guard hasNewMessagesSeparator else { return false }
        
        for (idx, model) in self.models.enumerated().reversed() where model is ChatNewMessagesSeparatorModel {
            self.models.remove(at: idx)
            hasNewMessagesSeparator = false
            return true
        }
        
        assert(false, "Situation is impossible")
        return false
    }
    
    private func process(response: TeambrellaResponseType, isPrevious: Bool, isMyNewMessage: Bool) {
        let count = self.count
        switch response {
        case let .chat(model):
            processCommonChat(model: model, isPrevious: isPrevious)
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
    }

    private func processCommonChat(model: ChatModel, isPrevious: Bool) {
        addModels(models: model.discussion.chat, isPrevious: isPrevious, chatModel: model)
        chatModel = model
        if model.discussion.chat.isEmpty {
            if isPrevious {
                hasPrevious = false
            } else {
                hasNext = false
                forwardOffset = 0
            }
        }
        teamAccessLevel = model.team?.accessLevel ?? .noAccess

        addClaimPaidIfNeeded(date: model.basic?.paymentFinishedDate)
    }

    private func addClaimPaidIfNeeded(date: Date?) {
        guard !isClaimPaidModelAdded, let date = date else { return }

        let model = ChatClaimPaidCellModel(date: date)
        addCellModels(models: [model])
        isClaimPaidModelAdded = true
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
