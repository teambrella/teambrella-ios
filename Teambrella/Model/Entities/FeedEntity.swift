//
//  FeedEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

struct FeedEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case amount = "Amount"
        case teamVote = "TeamVote"
        case topicID = "TopicId"
        case isVoting = "IsVoting"
        case payProgress = "PayProgress"
        case itemType = "ItemType"
        case itemID = "ItemId"
        case itemUserID = "ItemUserId"
        case itemDate = "ItemDate"
        case smallPhotoOrAvatar = "SmallPhotoOrAvatar"
        case modelOrName = "ModelOrName"
        case chatTitle = "ChatTitle"
        case unreadCount = "UnreadCount"
        case posterCount = "PosterCount"
        case topPosterAvatars = "TopPosterAvatars"
    }
    
    let text: SaneText
    let amount: Double?
    let teamVote: Double?
    let topicID: String
    let isVoting: Bool?
    let payProgress: Double?
    let itemType: ItemType
    let itemID: Int
    let itemUserID: String
    let itemDate: Date?
    let smallPhotoOrAvatar: String
    let modelOrName: String?
    let chatTitle: String?
    let unreadCount: Int
    let posterCount: Int
    let topPosterAvatars: [Avatar]

    /*
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decode(SaneText.self, forKey: .text)
        let itemType = try container.decode(Int.self, forKey: .itemType)
        let itemDate = try container.decode(String.self, forKey: .itemDate)

        self.itemType = ItemType(rawValue: itemType) ?? .teammate
        self.itemDate = DateFormatter.teambrella.date(from: itemDate)

        self.topicID = try container.decode(String.self, forKey: .topicID)
        self.itemID = try container.decode(Int.self, forKey: .itemID)
        self.itemUserID = try container.decode(String.self, forKey: .itemUserID)
        self.unreadCount = try container.decode(Int.self, forKey: .unreadCount)
        self.posterCount = try container.decode(Int.self, forKey: .posterCount)
        self.topPosterAvatars = try container.decode([Avatar].self, forKey: .topPosterAvatars)

        self.amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        self.teamVote = try container.decodeIfPresent(Double.self, forKey: .teamVote)
        self.isVoting = try container.decodeIfPresent(Bool.self, forKey: .isVoting)
        self.smallPhotoOrAvatar = try container.decode(String.self, forKey: .smallPhotoOrAvatar)
        self.modelOrName = try container.decodeIfPresent(String.self, forKey: .modelOrName)
        self.chatTitle = try container.decodeIfPresent(String.self, forKey: .chatTitle)

        self.payProgress = (try? container.decodeIfPresent(Double.self, forKey: .payProgress)) as? Double
    }
 */

}
