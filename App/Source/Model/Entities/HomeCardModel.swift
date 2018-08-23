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
        case hideCloseButton  = "HideCloseButton"
        case subtitle         = "SubTitle"
        case actionText       = "ActionText"
    }
    
    let text: SaneText
    let itemType: ItemType
    let itemID: Int
    let itemDate: Date
    let smallPhoto: Photo
    let amount: Fiat
    let teamVote: Double
    let isVoting: Bool
    let unreadCount: Int
    let chatTitle: String
    let payProgress: Double
    let itemName: String
    let userID: String
    let topicID: String
    let userName: Name
    let userAvatar: String
    let posterCount: Int
    let topPosterAvatars: [String]
    let year: Year
    let hideCloseButton: Bool
    let subtitle: String
    let actionText: SaneText
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(SaneText.self, forKey: .text)
        itemType = try container.decode(ItemType.self, forKey: .itemType)
        itemID = try container.decode(Int.self, forKey: .itemID)
        itemDate = try container.decode(Date.self, forKey: .itemDate)
        smallPhoto = try container.decode(Photo.self, forKey: .smallPhoto)
        let amount = try? container.decode(Fiat.self, forKey: .amount)
        self.amount = amount ?? Fiat.init(0)
        let teamVote = try? container.decode(Double.self, forKey: .teamVote)
        self.teamVote = teamVote ?? 0
        let isVoting = try? container.decode(Bool.self, forKey: .isVoting)
        self.isVoting = isVoting ?? false
        unreadCount = try container.decode(Int.self, forKey: .unreadCount)
        let chatTitle = try? container.decode(String.self, forKey: .chatTitle)
        self.chatTitle = chatTitle ?? ""
        let payProgress = try? container.decode(Double.self, forKey: .payProgress)
        self.payProgress = payProgress ?? 0
        let itemName = try? container.decode(String.self, forKey: .itemName)
        self.itemName = itemName ?? ""
        userID = try container.decode(String.self, forKey: .userID)
        let topicID = try? container.decode(String.self, forKey: .topicID)
        self.topicID = topicID ?? ""
        let userName = try? container.decode(Name.self, forKey: .userName)
        self.userName = userName ?? Name(fullName: "")
        let userAvatar = try? container.decode(String.self, forKey: .userAvatar)
        self.userAvatar = userAvatar ?? ""
        let posterCount = try? container.decode(Int.self, forKey: .posterCount)
        self.posterCount = posterCount ?? 0
        let topPosterAvatars = try? container.decode([String].self, forKey: .topPosterAvatars)
        self.topPosterAvatars = topPosterAvatars ?? []
        let year = try? container.decode(Year.self, forKey: .year)
        self.year = year ?? Year.init(0)
        let hideCloseButton = try? container.decode(Bool.self, forKey: .hideCloseButton)
        self.hideCloseButton = hideCloseButton ?? true
        let subtitle = try? container.decode(String.self, forKey: .subtitle)
        self.subtitle = subtitle ?? ""
        let actionText = try? container.decode(SaneText.self, forKey: .actionText)
        self.actionText = actionText ?? SaneText(text: "")
    }
    
}
