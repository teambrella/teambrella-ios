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

struct RemotePayload {
    let dict: [AnyHashable: Any]
    
    var type: RemoteCommandType { return (dict["Cmd"] as? Int).flatMap { RemoteCommandType(rawValue: $0) } ?? .unknown }
    
    var teamID: Int? { return dict["TeamId"] as? Int }
    var userID: String? { return dict["UserId"] as? String }
    var topicID: String? { return dict["TopicId"] as? String }
    var postID: String? { return dict["PostId"] as? String }
    var name: String? { return dict["UserName"] as? String }
    var text: String? { return dict["Text"] as? String }
    var claimID: Int? { return dict["ClaimId"] as? Int }
    var amount: String? { return dict["Count"] as? String }
    var teamURL: String? { return dict["TeamUrl"] as? String }
    var teamName: String? { return dict["TeamName"] as? String }
    var cryptoAmount: String? { return dict["CryptoAmount"] as? String }
    var currencyAmount: String? { return dict["CurrencyAmount"] as? String }
    var postsCount: Int? { return dict["Count"] as? Int }
    var teammateID: Int? { return dict["TeammateId"] as? Int }
    
    var avatar: String? { return dict["Avatar"] as? String }
    var image: String? { return dict["TeamUrl"] as? String }
}

struct RemoteMessage {
    let payload: RemotePayload
    
    var title: String? {
        switch payload.type {
        case .createdPost:
            return "New post"
        case .topicMessageNotification:
            return "New message"
        case .newTeammate:
            return "New teammate"
        case .postsSinceInteracted:
            return "You have \(payload.postsCount ?? 0) unread messages"
        default:
            return nil
        }
    }
    
    var subtitle: String? {
        switch payload.type {
        case .createdPost:
            return nil
        case .topicMessageNotification:
            return payload.name
        case .newTeammate:
            return payload.name
        default:
            return nil
        }
    }
    
    var body: String? {
        switch payload.type {
        case .createdPost:
            return payload.text
        default:
            return nil
        }
    }
    
    var avatar: String? { return payload.avatar }
    
    var image: String? {
        switch payload.type {
        case .newClaim,
             .walletFunded:
            return payload.teamURL
        default:
            return nil
        }
    }
}

enum RemoteCommandType: Int {
    case unknown = 0
    
    case createdPost = 1
    case deletedPost = 2
    case typing = 3
    case newClaim = 4
    case privateMessage = 5
    case walletFunded = 6
    case postsSinceInteracted = 7
    case newTeammate = 8
    case newDiscussion = 9
    
    case topicMessageNotification = 21
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
        teamURL: String,
        teamName: String)
    case privateMessage(userID: String,
        name: String,
        avatar: String,
        text: String)
    case walletFunded(teamID: Int,
        userID: String,
        cryptoAmount: String,
        currencyAmount: String,
        teamURL: String,
        teamName: String)
    case postsSinceInteracted(count: Int)
    case newTeammate(teamID: Int,
        userID: String,
        teammateID: Int,
        name: String,
        avatar: String,
        teamName: String)
    
    case newDiscussion
    case topicMessage
    
    // swiftlint:disable:next function_body_length
    static func command(from payload: RemotePayload) -> RemoteCommand {
        let teamID = payload.teamID ?? 0
        let userID = payload.userID ?? ""
        let topicID = payload.topicID ?? ""
        
        switch payload.type {
        case .createdPost:
            return .createdPost(teamID: teamID,
                                userID: userID,
                                topicID: topicID,
                                postID: payload.postID ?? "",
                                name: payload.name ?? "",
                                avatar: payload.avatar ?? "",
                                text: payload.text ?? "")
        case .deletedPost:
            return .deletedPost(teamID: teamID,
                                userID: userID,
                                topicID: topicID,
                                postID: payload.postID ?? "")
        case .typing:
            return .typing(teamID: teamID,
                           userID: userID,
                           topicID: topicID,
                           name: payload.name ?? "")
        case .newClaim:
            return .newClaim(teamID: teamID,
                             userID: userID,
                             claimID: payload.claimID ?? 0,
                             name: payload.name ?? "",
                             avatar: payload.avatar ?? "",
                             amount: payload.amount ?? "",
                             teamURL: payload.teamURL ?? "",
                             teamName: payload.teamName ?? ""
            )
        case .privateMessage:
            return .privateMessage(userID: userID,
                                   name: payload.name ?? "",
                                   avatar: payload.avatar ?? "",
                                   text: payload.text ?? "")
        case .walletFunded:
            return .walletFunded(teamID: teamID,
                                 userID: userID,
                                 cryptoAmount: payload.cryptoAmount ?? "",
                                 currencyAmount: payload.currencyAmount ?? "",
                                 teamURL: payload.teamURL ?? "",
                                 teamName: payload.teamName ?? "")
        case .postsSinceInteracted:
            return .postsSinceInteracted(count: payload.postsCount ?? 0)
        case .topicMessageNotification:
            return .topicMessage
        case .newTeammate:
            return .newTeammate(teamID: teamID,
                                userID: userID,
                                teammateID: payload.teammateID ?? 0,
                                name: payload.name ?? "",
                                avatar: payload.avatar ?? "",
                                teamName: payload.teamName ?? "")
        default:
            return .unknown(payload: payload)
        }
    }
}
