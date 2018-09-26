//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation

class UniversalChatContext {
    var claimID: Int?
    var topicID: String?
    var teamID: Int?
    var userID: String?

    var title: String?
    var canLoadBackward: Bool = true

    var requestType: TeambrellaPostRequestType = .teammateChat
    var postType: TeambrellaPostRequestType = .newPost

    var isPrivate: Bool { return requestType == .privateChat }
    var isRateNeeded: Bool { return type == .application || type == .claim }

    var type: UniversalChatType?

    init() {
        
    }

    init(_ claim: ClaimEntityLarge) {
        title = "Team.Chat.TypeLabel.claim".lowercased().capitalized + ": \(claim.id)"
        requestType = .claimChat
        claimID = claim.id
        topicID =  claim.discussion.id
        type = .claim
    }

    init(_ teammate: TeammateLarge) {
        title = teammate.basic.name.short

        teamID = teammate.basic.teamID
        userID = teammate.basic.id
        topicID = teammate.topic.id
        type = .application
    }

    init(_ applicationDetails: MyApplicationDetails) {
        userID = applicationDetails.userID
        teamID = service.session?.currentTeam?.teamID
        topicID = applicationDetails.topicID
        type = .application
    }

    init(_ feed: FeedEntity) {
        title = feed.chatTitle ?? feed.modelOrName
        requestType = TeambrellaPostRequestType.with(itemType: feed.itemType)
        claimID = feed.itemID
        teamID = service.session?.currentTeam?.teamID
        userID = feed.itemUserID
        topicID = feed.topicID
        type = UniversalChatType.with(itemType: feed.itemType)
    }

    init(_ homeCardModel: HomeCardModel) {
        title = homeCardModel.chatTitle
        requestType = TeambrellaPostRequestType.with(itemType: homeCardModel.itemType)

        claimID = homeCardModel.itemID
        teamID = service.session?.currentTeam?.teamID
        userID = homeCardModel.userID
        topicID = homeCardModel.topicID
    }

    init(_ remoteDetails: RemoteTopicDetails) {
        title = (remoteDetails as? RemotePayload.Discussion)?.topicName
        switch remoteDetails {
        case let details as RemotePayload.Claim:
            requestType = .claimChat
            claimID = details.claimID
        case let details as RemotePayload.Teammate:
            requestType = .teammateChat
            teamID = service.session?.currentTeam?.teamID
            userID = details.userID
        default:
            requestType = .feedChat
        }

        topicID = remoteDetails.topicID
    }

    init(_ chatModel: ChatModel) {
        title = chatModel.basic?.title
        requestType = .feedChat

        topicID = chatModel.discussion.topicID

    }

    init(_ privateUser: PrivateChatUser) {
        title = privateUser.name
        requestType = .privateChat
        postType = .newPrivatePost

        userID = privateUser.id
    }

    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        claimID.map { body.payload?["claimId"] = $0 }
        teamID.map { body.payload?["teamid"] = $0 }
        userID.map { body.payload?["userid"] = $0 }
        topicID.map { body.payload?["topicid"] = $0 }

        return updateIfPrivateChat(body: body)
    }

    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        topicID.map { body.payload?["topicId"] = $0 }

        return updateIfPrivateMessage(body: body)
    }

    private func updateIfPrivateChat(body: RequestBody) -> RequestBody {
        guard requestType == .privateChat else { return body }

        var body = body
        body.payload?["avatarSize"] = nil
        body.payload?["commentAvatarSize"] = nil
        return body
    }

    private func updateIfPrivateMessage(body: RequestBody) -> RequestBody {
        guard requestType == .privateChat else { return body }

        var body = body
        body.payload?["ToUserId"] = userID
        if let newPostID = body.payload?["NewPostId"] as? String {
            body.payload?["NewMessageId"] = newPostID
        }
        body.payload?["NewPostId"] = nil
        return body
    }

}
