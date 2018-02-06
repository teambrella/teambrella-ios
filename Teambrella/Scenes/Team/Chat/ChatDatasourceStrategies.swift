//
//  ChatDatasourceStrategies.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.07.17.

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

protocol ChatDatasourceStrategy {
    var title: String { get }
    var requestType: TeambrellaRequestType { get }
    //    var createChatType: TeambrellaRequestType { get }
    var postType: TeambrellaRequestType { get }
    var canLoadBackward: Bool { get }
    //var isRateVisible: Bool { get }
    
    func updatedChatBody(body: RequestBody) -> RequestBody
    func updatedMessageBody(body: RequestBody) -> RequestBody
}

struct ChatStrategyFactory {
    static func strategy(with context: ChatContext) -> ChatDatasourceStrategy {
        switch context {
        case let .claim(claim):
            return ClaimChatStrategy(context: claim)
        case let .teammate(teammate):
            return TeammateChatStrategy(context: teammate)
        case let .feed(feedEntity):
            return FeedChatStrategy(context: feedEntity)
        case let .home(card):
            return HomeChatStrategy(context: card)
        case let .chat(chatModel):
            return ChatStrategy(context: chatModel)
        case let .privateChat(user):
            return PrivateChatStrategy(context: user)
        case let .remote(details):
            return RemoteChatStrategy(context: details)
        case .none:
            return EmptyChatStrategy()
        }
    }
}

class EmptyChatStrategy: ChatDatasourceStrategy {
    var title: String = "Empty"
    var requestType: TeambrellaRequestType = .claimChat
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = false
    //  var isRateVisible: Bool = false
    
    func updatedChatBody(body: RequestBody) -> RequestBody { return body }
    func updatedMessageBody(body: RequestBody) -> RequestBody { return body }
    
}

class ClaimChatStrategy: ChatDatasourceStrategy {
    var title: String { return "Team.Chat.TypeLabel.claim".lowercased().capitalized + ": \(claim.id)" }
    var requestType: TeambrellaRequestType = .claimChat
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = true
    // var isRateVisible: Bool = true
    
    var claim: ClaimEntityLarge
    
    init(context: ClaimEntityLarge) {
        claim = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["claimId"] = claim.id
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] =  claim.discussion.id
        return body
    }
    
}

class TeammateChatStrategy: ChatDatasourceStrategy {
    var title: String { return teammate.basic.name.short }
    var requestType: TeambrellaRequestType = .teammateChat
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = true
    // var isRateVisible: Bool = true
    
    var teammate: TeammateLarge
    
    init(context: TeammateLarge) {
        teammate = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["teamid"] = teammate.basic.teamID
        body.payload?["userid"] = teammate.basic.id
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = teammate.topic.id
        return body
    }
    
}

class FeedChatStrategy: ChatDatasourceStrategy {
    var title: String { return feedEntity.chatTitle ?? feedEntity.modelOrName ?? "" }
    var requestType: TeambrellaRequestType {
        switch feedEntity.itemType {
        case .claim:
            return .claimChat
        case .teammate:
            return .teammateChat
        default:
            return .feedChat
        }
    }
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    
    var feedEntity: FeedEntity
    var canLoadBackward: Bool = true
    var isRateVisible: Bool = true
    
    init(context: FeedEntity) {
        feedEntity = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        switch feedEntity.itemType {
        case .claim:
            body.payload?["claimId"] = feedEntity.itemID
        case .teammate:
            body.payload?["teamid"] = service.session?.currentTeam?.teamID ?? 0
            body.payload?["userid"] = feedEntity.itemUserID
        default:
            body.payload?["TopicId"] = feedEntity.topicID
        }
        
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = feedEntity.topicID
        return body
    }
    
}

class HomeChatStrategy: ChatDatasourceStrategy {
    var title: String { return card.chatTitle ?? card.name.short }
    var requestType: TeambrellaRequestType {
        switch card.itemType {
        case .claim:
            return .claimChat
        case .teammate:
            return .teammateChat
        default:
            return .feedChat
        }
    }
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = true
    // var isRateVisible: Bool = true
    
    var card: HomeCardModel
    
    init(context: HomeCardModel) {
        card = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        switch card.itemType {
        case .claim:
            body.payload?["claimId"] = card.itemID
        case .teammate:
            body.payload?["teamid"] = service.session?.currentTeam?.teamID ?? 0
            body.payload?["userid"] = card.userID
        default:
            body.payload?["TopicId"] = card.topicID
        }
        
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = card.topicID
        return body
    }
    
}

class RemoteChatStrategy: ChatDatasourceStrategy {
    var title: String {
        return details.topicName
    }
    var requestType: TeambrellaRequestType {
        switch details {
        case _ as RemotePayload.Claim:
            return .claimChat
        case _ as RemotePayload.Teammate:
            return .teammateChat
        default:
            return .feedChat
        }
    }
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = true
    // var isRateVisible: Bool = true
    
    var details: RemoteTopicDetails
    
    init(context: RemoteTopicDetails) {
        details = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        switch details {
        case let details as RemotePayload.Claim:
            body.payload?["claimId"] = details.claimID
        case let details as RemotePayload.Teammate:
            body.payload?["teamid"] = service.session?.currentTeam?.teamID ?? 0
            body.payload?["userid"] = details.userID
        default:
            body.payload?["TopicId"] = details.topicID
        }
        
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = details.topicID
        return body
    }
    
}

class ChatStrategy: ChatDatasourceStrategy {
    var title: String { return chatModel.basic?.title ?? "" }
    var requestType: TeambrellaRequestType { return .feedChat }
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPost
    var canLoadBackward: Bool = true
    // var isRateVisible: Bool = true
    
    var chatModel: ChatModel
    
    init(context: ChatModel) {
        chatModel = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = chatModel.topicID
        
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] = chatModel.topicID
        return body
    }
    
}

class PrivateChatStrategy: ChatDatasourceStrategy {
    var title: String {
        return user.name }
    var requestType: TeambrellaRequestType { return .privateChat }
    //    var createChatType: TeambrellaRequestType = .newChat
    var postType: TeambrellaRequestType = .newPrivatePost
    var canLoadBackward: Bool = true
    //var isRateVisible: Bool = false
    
    var user: PrivateChatUser
    
    init(context: PrivateChatUser) {
        user = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["UserId"] = user.id
        body.payload?["avatarSize"] = nil
        body.payload?["commentAvatarSize"] = nil
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        guard let payload = body.payload else { return body }
        
        var body = body
        body.payload?["ToUserId"] = user.id
        body.payload?["NewMessageId"] = payload["NewPostId"]
        body.payload?["NewPostId"] = nil
        return body
    }
}
