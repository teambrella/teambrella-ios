//
//  TeammateTransformer.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.09.2017.
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

struct TeammateTransformer {
    let teammate: TeammateEntity?
    let extendedTeammate: ExtendedTeammateEntity?
    
    var privateChatUser: PrivateChatUser? {
        var dict: [String: Any] = [:]
        if let teammate = teammate {
            dict = ["UserId": teammate.userID,
                    "Avatar": teammate.avatar,
                    "Name": teammate.name,
                    "Text": teammate.extended?.topic.originalPostText ?? "",
                    "UnreadCount": teammate.extended?.topic.unreadCount ?? 0,
                    "SinceLastMessageMinutes": teammate.extended?.topic.minutesSinceLastPost ?? 0
            ]
            
        } else if let extended = extendedTeammate {
            dict = ["UserId": extended.basic.id,
                    "Avatar": extended.basic.avatar,
                    "Name": extended.basic.name,
                    "Text": extended.topic.originalPostText,
                    "UnreadCount": extended.topic.unreadCount,
                    "SinceLastMessageMinutes": extended.topic.minutesSinceLastPost
            ]
        }
        let json = JSON(dict)
        return PrivateChatUser(json: json)
    }
    
}
