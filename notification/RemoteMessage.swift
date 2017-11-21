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
    
    var title: String? {
        switch payload.type {
        case .createdPost:
            return "Push.newPost".localized
        case .newTeammate:
            return "Push.newTeammate".localized
        case .postsSinceInteracted:
            return "Push.unreadMessages_format".localized(payload.postsCount ?? "")
        case .walletFunded:
            return "Push.walletFunded".localized
        case .topicMessage:
            return "Push.newMessage".localized
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
            return "Push.walletFunded.message_format".localized(payload.teamNameValue,
                                                                payload.cryptoAmountValue,
                                                                payload.currencyAmountValue)
        case .topicMessage:
            return "Push.newMessage.posted_format".localized(payload.userNameValue,
                                                             payload.topicNameValue)
        case .postsSinceInteracted:
            return ""
        default:
            return nil
        }
    }
    
    var avatar: String? { return payload.avatar }
    var image: String? { return payload.image }
    
}
