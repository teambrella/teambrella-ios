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
            return "New post"
        case .newTeammate:
            return "New teammate"
        case .postsSinceInteracted:
            return "You have \(payload.postsCount ?? 0) unread messages"
        case .walletFunded:
            return "Wallet is funded"
        case .topicMessage:
            return "New message"
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
            return "Team: \(payload.teamNameValue)"
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
            return """
            Wallet for team \(payload.teamNameValue) is funded for \(payload.cryptoAmountValue)mETH \
            (\(payload.currencyAmountValue))
            """
        case .topicMessage:
            return "\(payload.userNameValue) posted in \(payload.topicNameValue)"
        default:
            return nil
        }
    }
    
    var avatar: String? { return payload.avatar }
    var image: String? { return payload.image }
    
}
