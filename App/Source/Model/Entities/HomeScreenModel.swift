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
import SwiftyJSON

struct HomeScreenModel {
    
    struct Card {
        let json: JSON
        let text: String
        var itemType: ItemType { return ItemType(rawValue: json["ItemType"].intValue) ?? .teammate }
        var itemID: Int { return json["ItemId"].intValue }
        var itemDate: Date? { return json["ItemDate"].stringValue.dateFromTeambrella }
        var smallPhoto: String { return json["SmallPhotoOrAvatar"].stringValue }
        var amount: Double { return json["Amount"].doubleValue }
        var teamVote: Double? { return json["TeamVote"].double }
        var isVoting: Bool { return json["IsVoting"].boolValue }
        //var text: String { return json["Text"].stringValue }
        var unreadCount: Int { return json["UnreadCount"].intValue }
        var isMine: Bool { return json["IsMine"].boolValue }
        var chatTitle: String? { return json["ChatTitle"].string }
        var payProgress: Double { return json["PayProgress"].doubleValue }
        var name: String? { return json["Name"].stringValue }
        var model: String? { return json["Model"].stringValue }
        var modelOrName: String { return json["ModelOrName"].stringValue }
        var userID: String { return json["ItemUserId"].stringValue }
        var topicID: String { return json["TopicId"].stringValue }
        
        init(json: JSON) {
            self.json = json
            self.text = TextAdapter().parsedHTML(string: json["Text"].stringValue)
        }
    }
    
    let json: JSON
    var cards: [Card]
    var teamPart: JSON { return json["TeamPart"] }
    
    var userID: String { return json["UserId"].stringValue }
    var facebookID: String { return json["FBName"].stringValue }
    var name: Name { return Name(fullName: json["Name"].stringValue) }
    var avatar: String { return json["Avatar"].stringValue }
    var unreadCount: Int { return json["UnreadCount"].intValue }
    var balance: Double { return json["CryptoBalance"].doubleValue }
    var coverage: Double { return json["Coverage"].doubleValue }
    var objectName: String { return json["ObjectName"].stringValue }
    var smallPhoto: String { return json["SmallPhoto"].stringValue }
    var haveVotingClaims: Bool { return json["HaveVotingClaims"].boolValue }
    var currency: String { return teamPart["Currency"].stringValue }
    var coverageType: CoverageType { return CoverageType(rawValue: teamPart["CoverageType"].intValue) ?? .other }
    var teamAccessLevel: Int { return teamPart["TeamAccessLevel"].intValue }
    
    init(json: JSON) {
        self.json = json
        cards = json["Cards"].arrayValue.flatMap { Card(json: $0) }
    }
}
