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
    let text: SaneText
    let amount: Double?
    let teamVote: Double?
    let topicID: String
    let isVoting: Bool?
    let payProgress: Double?
    let itemType: ItemType
    let itemID: Int
    let itemUserAvatar: Avatar?
    let itemUserName: Name
    let itemUserID: String
    let itemDate: Date?
    let smallPhotoOrAvatar: String
    let modelOrName: String?
    let chatTitle: String?
    let unreadCount: Int
    let posterCount: Int
    let topPosterAvatars: [Avatar]
    let year: Year?

    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case amount = "Amount"
        case teamVote = "TeamVote"
        case topicID = "TopicId"
        case isVoting = "IsVoting"
        case payProgress = "PayProgress"
        case itemType = "ItemType"
        case itemID = "ItemId"
        case itemUserAvatar = "ItemUserAvatar"
        case itemUserName = "ItemUserName"
        case itemUserID = "ItemUserId"
        case itemDate = "ItemDate"
        case smallPhotoOrAvatar = "SmallPhotoOrAvatar"
        case modelOrName = "ModelOrName"
        case chatTitle = "ChatTitle"
        case unreadCount = "UnreadCount"
        case posterCount = "PosterCount"
        case topPosterAvatars = "TopPosterAvatars"
        case year = "Year"
    }
    
}
