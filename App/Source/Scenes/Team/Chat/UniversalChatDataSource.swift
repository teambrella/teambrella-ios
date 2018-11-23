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
    
    var notificationsType: MuteType            = .unknown
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
            notificationsType = MuteType.type(from: chatModel?.discussion.isMuted)
            cellModelBuilder.showRate = chatType == .application || chatType == .claim
        }
    }
    
    private var models: [ChatCellModel]             = []
    private var unsentIDs: Set<String>              = []
    
    private var lastInsertionIndex                  = 0
    
    private var strategy: UniversalChatContext      = UniversalChatContext()
    var cellModelBuilder                            = ChatModelBuilder()
    
    private var lastRead: UInt64 { return chatModel?.discussion.lastRead ?? 0 }
    private var currentLimit: Int                   = 0
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
    private var isPayToJoinModelAdded               = false
    private var isAddMorePhotoModelAdded            = false
    
    private var topCellDate: Date?
    
    var myVote: Double? {
        return chatModel?.voting?.myVote
    }
    
    var claimDate: Date? {
        return chatModel?.basic?.incidentDate
    }
    
    var topicID: String? { return strategy.topicID ?? chatModel?.discussion.topicID }
    
    var count: Int { return models.count }
    
    var dao: DAO { return service.dao }
    
    var title: String {
        guard !strategy.isPrivate else { return strategy.title ?? "" }
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
        if isPrivateChat { return .privateChat }
        if chatModel?.basic?.claimAmount != nil { return .claim }
        if chatModel?.basic?.title != nil { return .discussion }
        if chatModel?.basic?.userID != nil { return .application }
        
        if let type = strategy.type { return type }
        
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
    
    var isPrivateChat: Bool { return strategy.isPrivate }
    
    var isPrejoining: Bool {
        guard let accessLevel = chatModel?.team?.accessLevel else { return false }

        return accessLevel == .readOnlyAllAndStealth
    }

    var isInputAllowed: Bool {
        if isPrivateChat { return true }
        guard let teamID = chatModel?.team?.teamID,
            let myTeamID = service.session?.currentTeam?.teamID else { return false }
        
        var isAllowed: Bool = teamID == myTeamID
        
        if let accessLevel = chatModel?.team?.accessLevel {
            switch accessLevel {
            case .hiddenDetailsAndEditMine,
                 .hiddenDetailsAndStealth,
                 .readAllAndEditMine,
                 .readOnlyAllAndStealth:
                if chatType == .application,
                    let chatUserID = chatModel?.basic?.userID,
                    let myID = service.session?.currentUserID {
                    isAllowed = chatUserID == myID
                } else {
                    isAllowed = false
                }
            case .noAccess,
                 .readOnly:
                isAllowed = false
            default:
                break
            }
        }
        return isAllowed
    }
    
    func mute(type: MuteType, completion: @escaping (Bool) -> Void) {
        guard let topicID = chatModel?.discussion.topicID else { return }
        
        let isMuted = type == .muted
        dao.mute(topicID: topicID, isMuted: isMuted).observe { [weak self] result in
            switch result {
            case let .value(muted):
                self?.notificationsType = MuteType.type(from: muted)
                completion(muted)
            case let .error(error):
                log("\(error)", type: [.error, .serverReply])
            }
        }
    }
    
    func addContext(context: UniversalChatContext) {
        strategy = context
        hasPrevious = strategy.canLoadBackward
        cellModelBuilder.showRate = context.isRateNeeded
        cellModelBuilder.showTheirAvatar = !context.isPrivate
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

    func newPhotoMeta() -> ChatMetadata? {
        guard !isLoading, let topicID = topicID else { return nil }

        let postID = UUID().uuidString
        return ChatMetadata(topicID: topicID, postID: postID)
    }

    func addNewUnsentPhoto(metadata: ChatMetadata) {
        let model = ChatUnsentImageCellModel(id: metadata.postID, date: Date())
        unsentIDs.insert(metadata.postID)
        addCellModel(model: model)
    }

    /**
     Returns index of post model with the given id

     Because most of the time we need index of one of the latest posts, search is done from end to beginning
 */
    func indexPath(postID: String) -> IndexPath? {
        for (idx, model) in models.reversed().enumerated() where model.id == postID {
            return IndexPath(row: models.count - 1 - idx, section: 0)
        }
        return nil
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
        
        let body = strategy.updatedMessagePayload(body: ["Text": text,
                                                         "NewPostId": id,
                                                         "Images": images])
        if isPrivateChat {
            dao.sendPrivateChatMessage(type: strategy.postType, body: body).observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .value(model):
                    self.hasNext = true
                    self.isLoading = false
                    self.process(model: model, isPrevious: false)
                case let .error(error):
                    self.onError?(error)
                }
            }
        } else {
            dao.sendChatMessage(type: strategy.postType, body: body).observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .value(message):
                    self.hasNext = true
                    self.isLoading = false
                    self.processMyNew(message: message)
                case let .error(error):
                    self.onError?(error)
                }
            }
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

    func deleteMessage(id: String, completion: @escaping (Error?) -> Void) {
        dao.deletePost(id: id).observe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .value:
                for (idx, model) in self.models.enumerated() where model.id == id {
                    self.models.remove(at: idx)
                    break
                }
                completion(nil)
            case let .error(error):
                completion(error)
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
        
        self.currentLimit = Constant.limit
        
        var offset = previous
            ? self.backwardOffset
            : self.forwardOffset
        
        if self.isFirstLoad {
            self.currentLimit += Constant.firstLoadPreviousMessagesCount
            offset -= Constant.firstLoadPreviousMessagesCount
        }
        var payload: [String: Any] = ["limit": self.currentLimit,
                                      "offset": offset,
                                      "avatarSize": self.avatarSize,
                                      "commentAvatarSize": self.commentAvatarSize]
        if self.lastRead > 0 {
            payload["since"] = self.lastRead
        }
        payload = strategy.updatedChatBody(body: payload)
        
        dao.requestChat(type: strategy.requestType, body: payload).observe { [weak self] result in
            guard let`self` = self else { return }
            switch result {
            case let .value(chat):
                self.isLoading = false
                self.process(model: chat, isPrevious: previous)
            case let .error(error):
                self.onError?(error)
            }
        }
    }
    
    private func addCellModels(models: [ChatCellModel]) {
        let ids = models.map { $0.id }
        for id in ids where self.unsentIDs.contains(id) {
            self.unsentIDs.remove(id)
            if let index = indexPath(postID: id) {
                self.models.remove(at: index.row)
            }
        }
        models.forEach { self.addCellModel(model: $0) }
    }
    
    private func addCellModel(model: ChatCellModel) {
        guard !models.isEmpty else {
            models.append(model)
            return
        }
        
        // find the place in array where to insert new item
        if lastInsertionIndex >= models.count {
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
        addAddPhotoIfNeeded()
    }

    private func addAddPhotoIfNeeded() {
        guard isPrejoining, let model = models.last as? ChatCellModel else { return }
        guard model as? ChatImageCellModel != nil || model as? ChatUnsentImageCellModel != nil else { return }

        if isAddMorePhotoModelAdded {
            for (idx, model) in models.reversed().enumerated() {
                if let model = model as? ServiceMessageWithButtonCellModel, model.command == .addMorePhoto {
                    models.remove(at: models.count - 1 - idx)
                    break
                }
            }
        }

        let addPhotoModel = cellModelBuilder.addMorePhotoModel(lastDate: model.date)
        models.append(addPhotoModel)
        isAddMorePhotoModelAdded = true
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
    
    private func processMyNew(message: ChatEntity) {
        let models = createCellModels(from: [message], isTemporary: true)
        addCellModels(models: models)
        postsCount += 1
        forwardOffset = 0
        
        onSendMessage?(IndexPath(row: lastInsertionIndex, section: 0))
        isFirstLoad = false
    }
    
    private func process(model: ChatModel, isPrevious: Bool) {
        let count = self.count
        processCommonChat(model: model, isPrevious: isPrevious)
        let hasNewModels = self.count > count
        onUpdate?(isPrevious, hasNewModels, isFirstLoad)
        isFirstLoad = false
    }
    
    private func processCommonChat(model: ChatModel, isPrevious: Bool) {
        addModels(models: model.discussion.chat, isPrevious: isPrevious, chatModel: model)
        chatModel = model
        if model.discussion.chat.count < currentLimit {
            if isPrevious {
                hasPrevious = false
            } else {
                hasNext = false
                forwardOffset = 0
            }
        }
        if !isPrevious && model.discussion.lastRead == 0 {
            hasNext = false
        }
        
        teamAccessLevel = model.team?.accessLevel ?? .noAccess
        
        addClaimPaidIfNeeded(date: model.basic?.paymentFinishedDate)
        //addPayToJoinIfNeeded(date: model.basic?.datePayToJoin)
    }

    private func addClaimPaidIfNeeded(date: Date?) {
        guard !isClaimPaidModelAdded, let date = date else { return }
        
        let model = ChatClaimPaidCellModel(date: date)
        addCellModels(models: [model])
        isClaimPaidModelAdded = true
    }
    
    //    private func addPayToJoinIfNeeded(date: Date?) {
    //        guard !isPayToJoinModelAdded, let date = date else { return }
    //
    //        let model = ChatPayToJoinCellModel(date: date)
    //        addCellModels(models: [model])
    //        isPayToJoinModelAdded = true
    //    }
    
    private func createCellModels(from entities: [ChatEntity], isTemporary: Bool) -> [ChatCellModel] {
        cellModelBuilder.font = font
        cellModelBuilder.width = cloudWidth - labelHorizontalInset * 2
        let models = cellModelBuilder.cellModels(from: entities,
                                                 isClaim: strategy.requestType == .claimChat,
                                                 isTemporary: isTemporary)
        return models
    }
    
}
