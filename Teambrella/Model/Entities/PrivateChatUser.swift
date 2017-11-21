//
//  PrivateChatUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.08.17.
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

struct PrivateChatUser {
    //let json: JSON
    
    let id: String
    let avatar: String
    let name: String
    let text: String
    let unreadCount: Int
    let minutesSinceLast: Int
    
    init(json: JSON) {
        id = json["UserId"].stringValue
        avatar = json["Avatar"].stringValue
        name = json["Name"].stringValue
        text = json["Text"].stringValue
        unreadCount = json["UnreadCount"].intValue
        minutesSinceLast = json["SinceLastMessageMinutes"].intValue
    }
    
    init?(remoteCommand: RemoteCommand) {
        switch remoteCommand {
        case let .privateMessage(userID: userID,
                                 name: name,
                                 avatar: avatar,
                                 message: message):
            self.id = userID
            self.name = name
            self.avatar = avatar
            self.text = message
            self.unreadCount = 0
            self.minutesSinceLast = 0
        default:
            return nil
        }
    }
}
