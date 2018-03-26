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

struct RemoteMessage {
    let payload: RemotePayload
    /*
    case privateMessage = 5
    case walletFunded = 6
    case postsSinceInteracted = 7
    case newTeammate = 8
    case newDiscussion = 9
    
    case topicMessage = 21
    */
    var title: String? {
        switch payload.type {
        case .createdPost:
            return "Push.newPost".localized
        case .privateMessage:
            return "Push.privateMessage.title_format".localized(payload.userNameValue)
        case .newTeammate:
            return payload.teamNameValue
        case .postsSinceInteracted:
            return "Push.unreadMessages_format".localized(payload.postsCount ?? "")
        case .walletFunded:
            return "Push.walletFunded.title".localized
        case .topicMessage:
            return "Push.newMessage".localized
        case .newDiscussion:
            return "Push.newDiscussion.title_format".localized(payload.userNameValue, payload.topicNameValue)
        case .newClaim:
            return "Push.newClaim.title_format".localized(payload.userNameValue)
        default:
            return nil
        }
    }
    
    var subtitle: String? {
        switch payload.type {
        case .createdPost:
            return nil
        case .newTeammate:
            return payload.userName
        case .walletFunded:
            return "Push.team_format".localized(payload.teamNameValue)
        default:
            return nil
        }
    }
    
    var body: String? {
        switch payload.type {
        case .createdPost,
             .privateMessage:
            return payload.message
        case .walletFunded:
            return "Push.walletFunded.message_format".localized(payload.cryptoAmountValue)
        case .topicMessage:
            return "Push.newMessage.posted_format".localized(payload.userNameValue,
                                                             payload.topicNameValue)
        case .postsSinceInteracted:
            return ""
        case .newTeammate:
            return "Push.newTeammate.body_format".localized(payload.userNameValue)
        case .newClaim:
            return "Push.newClaim.body_format".localized(payload.amountValue)
        default:
            return nil
        }
    }
    
    var avatar: String? { return payload.avatar }
    var image: String? { return payload.image }
    
}
