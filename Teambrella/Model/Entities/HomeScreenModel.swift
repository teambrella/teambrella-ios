//
//  HomeScreenModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

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

struct HomeScreenModel: Decodable {
    
    struct Card: Decodable {
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case text        = "Text"
            case itemType    = "ItemType"
            case itemID      = "ItemId"
            case itemDate    = "ItemDate"
            case smallPhoto  = "SmallPhotoOrAvatar"
            case amount      = "Amount"
            case teamVote    = "TeamVote"
            case isVoting    = "IsVoting"
            case unreadCount = "UnreadCount"
            case chatTitle   = "ChatTitle"
            case payProgress = "PayProgress"
            case name        = "ModelOrName"
            case userID      = "ItemUserId"
            case topicID     = "TopicId"
        }
        
        let text: String
        let itemType: ItemType
        let itemID: Int
        let itemDate: Date
        let smallPhoto: String
        let amount: Double
        let teamVote: Double?
        let isVoting: Bool
        let unreadCount: Int
        let chatTitle: String?
        let payProgress: Double
        let name: String
        let userID: String
        let topicID: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let text = try container.decode(String.self, forKey: .text)
            self.text = TextAdapter().parsedHTML(string: text)
            self.itemType = try container.decode(ItemType.self, forKey: .itemType)
            self.itemID = try container.decode(Int.self, forKey: .itemID)
            let dateString = try container.decode(String.self, forKey: .itemDate)
            guard let date = Formatter.teambrella.date(from: dateString) else {
                throw TeambrellaErrorFactory.malformedDate(format: dateString)
            }
            
            self.itemDate = date
            self.smallPhoto = try container.decode(String.self, forKey: .smallPhoto)
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.teamVote = try container.decodeIfPresent(Double.self, forKey: .teamVote)
            self.isVoting = try container.decode(Bool.self, forKey: .isVoting)
            self.unreadCount = try container.decode(Int.self, forKey: .unreadCount)
            self.chatTitle = try container.decodeIfPresent(String.self, forKey: .chatTitle)
            self.payProgress = try container.decode(Double.self, forKey: .payProgress)
            self.name = try container.decode(String.self, forKey: .name)
            self.userID = try container.decode(String.self, forKey: .userID)
            self.topicID = try container.decode(String.self, forKey: .topicID)
        }
    
    }
    
    struct TeamPart: Decodable {
        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case currency = "Currency"
            case coverageType = "CoverageType"
            case teamAccessLevel = "TeamAccessLevel"
        }
        
        let currency: String
        let coverageType: CoverageType
        let teamAccessLevel: Int
        
    }
    
    enum CodingKeys: String, CodingKey {
        case cards            = "Cards"
        case userID           = "UserId"
        case facebookID       = "FBName"
        case name             = "Name"
        case avatar           = "Avatar"
        case unreadCount      = "UnreadCount"
        case balance          = "CryptoBalance"
        case coverage         = "Coverage"
        case objectName       = "ObjectName"
        case smallPhoto       = "SmallPhoto"
        case haveVotingClaims = "HaveVotingClaims"
        case teamPart         = "TeamPart"
    }

    var cards: [Card]
    let teamPart: TeamPart
    let userID: String
    let facebookID: UInt64?
    let name: Name
    let avatar: String
    let unreadCount: Int
    let balance: Double
    let coverage: Double
    let objectName: String
    let smallPhoto: String
    let haveVotingClaims: Bool
    
}
