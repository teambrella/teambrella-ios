//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct HomeCardModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case text             = "Text"
        case itemType         = "ItemType"
        case itemID           = "ItemId"
        case itemDate         = "ItemDate"
        case smallPhoto       = "SmallPhotoOrAvatar"
        case amount           = "Amount"
        case teamVote         = "TeamVote"
        case isVoting         = "IsVoting"
        case unreadCount      = "UnreadCount"
        case chatTitle        = "ChatTitle"
        case payProgress      = "PayProgress"
        case itemName         = "ModelOrName"
        case userID           = "ItemUserId"
        case topicID          = "TopicId"
        case userName         = "ItemUserName"
        case userAvatar       = "ItemUserAvatar"
        case posterCount      = "PosterCount"
        case topPosterAvatars = "TopPosterAvatars"
        case year             = "Year"
        case subtitle         = "SubTitle"
        case actionText       = "ActionText"

        case myPinVote        = "MyPin"
        case teamPinRate      = "TeamPin"
    }
    
    let text: SaneText
    let itemType: ItemType
    let itemID: Int
    let itemDate: Date
    let smallPhoto: Photo
    let amount: Fiat?
    let teamVote: Double?
    let isVoting: Bool?
    let unreadCount: Int
    let chatTitle: String?
    let payProgress: Double?
    let itemName: String?
    let userID: String
    let topicID: String?
    let userName: Name?
    let userAvatar: Avatar?
    let posterCount: Int?
    let topPosterAvatars: [String]?
    let year: Year?
    let subtitle: String?
    let actionText: SaneText?

    let myPinVote: Double
    let teamPinRate: Double
    
}
