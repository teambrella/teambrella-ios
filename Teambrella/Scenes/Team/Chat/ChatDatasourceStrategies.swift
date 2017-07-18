//
//  ChatDatasourceStrategies.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol ChatDatasourceStrategy {
    var title: String { get }
    var requestType: TeambrellaRequestType { get }
    var createChatType: TeambrellaRequestType { get }
    func updatedChatBody(body: RequestBody) -> RequestBody
    func updatedMessageBody(body: RequestBody) -> RequestBody
}

struct ChatStrategyFactory {
    static func strategy(with context: Any?) -> ChatDatasourceStrategy {
        if let claim = context as? EnhancedClaimEntity {
            return ClaimChatStrategy(context: claim)
        } else if let teammate = context as? ExtendedTeammate {
            return TeammateChatStrategy(context: teammate)
        } else if let feedEntity = context as? FeedEntity {
            return FeedChatStrategy(context: feedEntity)
        } else {
            return EmptyChatStrategy()
        }
    }
}

class EmptyChatStrategy: ChatDatasourceStrategy {
     var title: String = "Empty"
    var requestType: TeambrellaRequestType = .claimChat
    var createChatType: TeambrellaRequestType = .feedCreateChat
    
    func updatedChatBody(body: RequestBody) -> RequestBody { return body }
    func updatedMessageBody(body: RequestBody) -> RequestBody { return body }
    
}

class ClaimChatStrategy: ChatDatasourceStrategy {
    var title: String { return claim.name }
    var requestType: TeambrellaRequestType = .claimChat
    var createChatType: TeambrellaRequestType = .feedCreateChat
    
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
    var createChatType: TeambrellaRequestType = .feedCreateChat
    
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
    var createChatType: TeambrellaRequestType = .feedCreateChat
    
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
            body.payload?["teamid"] = service.session.currentTeam?.teamID ?? 0
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
