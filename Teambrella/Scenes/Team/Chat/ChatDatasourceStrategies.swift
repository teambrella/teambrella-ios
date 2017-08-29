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
    var createChatType: TeambrellaRequestType { get }
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
        case .none:
            return EmptyChatStrategy()
        }
    }
}

class EmptyChatStrategy: ChatDatasourceStrategy {
     var title: String = "Empty"
    var requestType: TeambrellaRequestType = .claimChat
    var createChatType: TeambrellaRequestType = .newChat
    
    func updatedChatBody(body: RequestBody) -> RequestBody { return body }
    func updatedMessageBody(body: RequestBody) -> RequestBody { return body }
    
}

class ClaimChatStrategy: ChatDatasourceStrategy {
    var title: String { return claim.name }
    var requestType: TeambrellaRequestType = .claimChat
    var createChatType: TeambrellaRequestType = .newChat
    
    var claim: EnhancedClaimEntity
    
    init(context: EnhancedClaimEntity) {
        claim = context
    }
    
    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["claimId"] = claim.id
        return body
    }
    
    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        body.payload?["TopicId"] =  claim.topicID
        return body
    }
    
}

class TeammateChatStrategy: ChatDatasourceStrategy {
    var title: String { return teammate.basic.name }
    var requestType: TeambrellaRequestType = .teammateChat
    var createChatType: TeambrellaRequestType = .newChat
    
    var teammate: ExtendedTeammate
    
    init(context: ExtendedTeammate) {
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
     var title: String { return feedEntity.chatTitle ?? feedEntity.modelOrName }
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
    var createChatType: TeambrellaRequestType = .newChat
    
    var feedEntity: FeedEntity
    
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
    var title: String { return card.chatTitle ?? card.name }
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
    var createChatType: TeambrellaRequestType = .newChat
    
    var card: HomeScreenModel.Card
    
    init(context: HomeScreenModel.Card) {
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

class ChatStrategy: ChatDatasourceStrategy {
    var title: String { return chatModel.title }
    var requestType: TeambrellaRequestType { return .feedChat }
    var createChatType: TeambrellaRequestType = .newChat
    
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
