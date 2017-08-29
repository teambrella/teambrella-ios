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
import SwiftyJSON

struct FeedEntity {
    let json: JSON
    let text: String
    
    var amount: Double { return json["Amount"].doubleValue }
    var teamVote: Double { return json["TeamVote"].doubleValue }
    var topicID: String { return json["TopicId"].stringValue }
    var isVoting: Bool { return json["IsVoting"].boolValue }
    var payProgress: Double { return json["PayProgress"].doubleValue }
    var itemType: ItemType { return ItemType(rawValue: json["ItemType"].intValue) ?? .teammate }
    var itemID: Int { return json["ItemId"].intValue }
    var itemUserID: String { return json["ItemUserId"].stringValue }
    var itemDate: Date? { return DateFormatter.teambrella.date(from: json["ItemDate"].stringValue) }
    var smallPhotoOrAvatar: String { return json["SmallPhotoOrAvatar"].stringValue }
    var modelOrName: String { return json["ModelOrName"].stringValue }
    var chatTitle: String? { return json["ChatTitle"].string }
    var unreadCount: Int { return json["UnreadCount"].intValue }
    var posterCount: Int { return json["PosterCount"].intValue }
    var topPosterAvatars: [String] { return json["TopPosterAvatars"].arrayObject as? [String] ?? [] }
    
    init(json: JSON) {
        self.json = json
        self.text = TextAdapter().parsedHTML(string: json["Text"].stringValue)
    }
    
}
