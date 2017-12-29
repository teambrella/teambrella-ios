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

struct TeammateAdaptor {
    let teammateLarge: TeammateLarge?
    
    var privateChatUser: PrivateChatUser? {
        var dict: [String: Any] = [:]
       if let teammateLarge = teammateLarge {
            dict = ["UserId": teammateLarge.basic.id,
                    "Avatar": teammateLarge.basic.avatar,
                    "Name": teammateLarge.basic.name.short,
                    "Text": teammateLarge.topic.originalPostText,
                    "UnreadCount": teammateLarge.topic.unreadCount,
                    "SinceLastMessageMinutes": teammateLarge.topic.minutesSinceLastPost
            ]
        }
        let json = JSON(dict)
        return PrivateChatUser(json: json)
    }
    
}
