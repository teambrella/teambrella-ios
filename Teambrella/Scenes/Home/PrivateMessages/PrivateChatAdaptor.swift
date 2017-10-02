//
//  PrivateChatAdaptor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
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
//

import Foundation
import SwiftyJSON

struct PrivateChatAdaptor {
    let json: JSON
    
    var adaptedMessages: [ChatEntity] {
        let discussion = json["DiscussionPart"]
        let basic = json["BasicPart"]
        let name = basic["Name"].stringValue
        let avatar = basic["Avatar"].stringValue
        let jsons = discussion["Chat"].arrayValue
        var messages: [ChatEntity] = []
        for item in jsons {
            var json = item
            let teammatePart = JSON(["Name": name,
                                     "Avatar": avatar])
            json["TeammatePart"] = teammatePart
            messages.append(ChatEntity(json: json))
        }
        return messages
    }
    
}
