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
import SwiftyJSON

struct ChatModel {
    let lastUpdated: Int64
    let discussion: JSON
    //let lastRead: Int64
    let chat: [ChatEntity]
    let basicPart: BasicPart?
    let teamPart: TeamPart?
    let votingPart: VotingPart?
    
    // teammateID or claimID
    let id: Int
    
    let title: String
    
    init(json: JSON, chat: [ChatEntity]) {
        lastUpdated = json["LastUpdated"].int64Value
        discussion = json["DiscussionPart"]
        self.chat = chat
        basicPart = BasicPartFactory.basicPart(from: json)
        teamPart = TeamPartFactory.teamPart(from: json)
        votingPart = VotingPartFactory.votingPart(from: json)
        title = json["Title"].stringValue
        id = json["Id"].intValue
    }
    
    // Discussion Part
    var topicID: String { return discussion["TopicId"].stringValue }
    var lastRead: Int64 { return discussion["LastRead"].int64Value }
    var isMuted: Bool? { return discussion["IsMuted"].bool }
}
