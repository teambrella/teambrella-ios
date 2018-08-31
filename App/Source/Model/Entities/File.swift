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

    // for private chat
    var avatarSize: CGFloat?
    var commentAvatarSize: CGFloat?
    var toUserID: String?
    var newMessageID: String?
    var newPostID: String?

    var title: String? = nil
    var canLoadBackward: Bool = true

    var requestType: TeambrellaRequestType = .teammateChat
    var postType: TeambrellaRequestType = .newPost

    init() {

    }

    init(_ claim: ClaimEntityLarge) {
        title = "Team.Chat.TypeLabel.claim".lowercased().capitalized + ": \(claim.id)"
        requestType = .claimChat
        claimID = claim.id
        topicID =  claim.discussion.id
    }

    init(_ teammate: TeammateLarge) {
        title = teammate.basic.name.short

        teamID = teammate.basic.teamID
        userID = teammate.basic.id
        topicID = teammate.topic.id
    }

    init(_ applicationDetails: MyApplicationDetails) {
        userID = applicationDetails.userID
        teamID = service.session?.currentTeam?.teamID
        topicID = applicationDetails.topicID
    }

    init(_ feed: FeedEntity) {
        title = feed.chatTitle ?? feed.modelOrName ?? nil
        requestType = TeambrellaRequestType.with(itemType: feed.itemType)
        claimID = feed.itemID
        teamID = service.session?.currentTeam?.teamID
        userID = feed.itemUserID
        topicID = feed.topicID
    }

    init(_ homeCardModel: HomeCardModel) {
        title = homeCardModel.chatTitle
        requestType = TeambrellaRequestType.with(itemType: homeCardModel.itemType)

        claimID = homeCardModel.itemID
        teamID = service.session?.currentTeam?.teamID
        userID = homeCardModel.userID
        topicID = homeCardModel.topicID
    }

    init(_ remoteDetails: RemoteTopicDetails) {

    }

    init(_ chatModel: ChatModel) {

    }

    init(_ privateUser: PrivateChatUser) {

    }

    func updatedChatBody(body: RequestBody) -> RequestBody {
        var body = body
        claimID.map { body.payload?["claimId"] = $0 }
        teamID.map { body.payload?["teamid"] = $0 }
        userID.map { body.payload?["userid"] = $0 }

        return body
    }

    func updatedMessageBody(body: RequestBody) -> RequestBody {
        var body = body
        topicID.map { body.payload?["topicId"] = $0 }

        return body
    }
}
