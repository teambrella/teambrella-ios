//
/* Copyright(C) 2017 Teambrella, Inc.
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

enum RemoteCommandType: Int {
    case unknown = 0
    
    // will come only from Sockets
    case deletedPost = 2
    case typing = 3

    // may come from Push
    case createdPost = 1

    case newClaim = 4
    case privateMessage = 5
    case walletFunded = 6
    case postsSinceInteracted = 7
    case newTeammate = 8
    case newDiscussion = 9
    
    case topicMessage = 21
}

enum RemoteCommand {
    case unknown(payload: RemotePayload)
    case createdPost(teamID: Int,
        userID: String,
        topicID: String,
        postID: String,
        name: String,
        avatar: String,
        text: String)
    case deletedPost(teamID: Int,
        userID: String,
        topicID: String,
        postID: String)
    case typing(teamID: Int,
        userID: String,
        topicID: String,
        name: String)
    case newClaim(teamID: Int,
        userID: String,
        claimID: Int,
        name: String,
        avatar: String,
        amount: String,
        teamName: String)
    
    case privateMessage(userID: String,
        name: String,
        avatar: String,
        message: String)
    case walletFunded(teamID: Int,
        userID: String,
        cryptoAmount: String,
        currencyAmount: String,
        teamLogo: String,
        teamName: String)
    case postsSinceInteracted(count: String)
    case newTeammate(teamID: Int,
        userID: String,
        teammateID: Int,
        name: String,
        avatar: String,
        teamName: String)
    
    case newDiscussion
    case topicMessage(topicID: String,
        topicName: String,
        userName: String,
        avatar: String,
        details: RemoteTopicDetails?)
    
    // swiftlint:disable:next function_body_length
    static func command(from payload: RemotePayload) -> RemoteCommand {
        
        switch payload.type {
        case .createdPost:
            return .createdPost(teamID: payload.teamIDValue,
                                userID: payload.userIDValue,
                                topicID: payload.topicIDValue,
                                postID: payload.postIDValue,
                                name: payload.userNameValue,
                                avatar: payload.image,
                                text: payload.messageValue)
        case .deletedPost:
            return .deletedPost(teamID: payload.teamIDValue,
                                userID: payload.userIDValue,
                                topicID: payload.topicIDValue,
                                postID: payload.postIDValue)
        case .typing:
            return .typing(teamID: payload.teamIDValue,
                           userID: payload.userIDValue,
                           topicID: payload.topicIDValue,
                           name: payload.userNameValue)
        case .newClaim:
            return .newClaim(teamID: payload.teamIDValue,
                             userID: payload.userIDValue,
                             claimID: payload.claimIDValue,
                             name: payload.userNameValue,
                             avatar: payload.image,
                             amount: payload.amountValue,
                             teamName: payload.teamNameValue
            )
        case .privateMessage:
            return .privateMessage(userID: payload.userIDValue,
                                   name: payload.userNameValue,
                                   avatar: payload.image,
                                   message: payload.messageValue)
        case .walletFunded:
            return .walletFunded(teamID: payload.teamIDValue,
                                 userID: payload.userIDValue,
                                 cryptoAmount: payload.cryptoAmountValue,
                                 currencyAmount: payload.currencyAmountValue,
                                 teamLogo: payload.image,
                                 teamName: payload.teamNameValue)
        case .postsSinceInteracted:
            return .postsSinceInteracted(count: payload.postsCountValue)
        case .topicMessage:
            return .topicMessage(topicID: payload.topicIDValue,
                                 topicName: payload.topicNameValue,
                                 userName: payload.userNameValue,
                                 avatar: payload.image,
                                 details: payload.topicDetails)
        case .newTeammate:
            return .newTeammate(teamID: payload.teamIDValue,
                                userID: payload.userIDValue,
                                teammateID: payload.teammateIDValue,
                                name: payload.userNameValue,
                                avatar: payload.image,
                                teamName: payload.teamNameValue)
        default:
            return .unknown(payload: payload)
        }
    }
}
