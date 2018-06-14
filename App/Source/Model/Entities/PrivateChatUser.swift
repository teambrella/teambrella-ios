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

struct PrivateChatUser: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "UserId"
        case avatar = "Avatar"
        case name = "Name"
        case text = "Text"
        case unreadCount = "UnreadCount"
        case minutesSinceLast = "SinceLastMessageMinutes"
    }
    
    let id: String
    let avatar: String
    let name: String
    let text: String
    let unreadCount: Int
    let minutesSinceLast: Int
    
    init(teammateLarge: TeammateLarge) {
        id = teammateLarge.basic.id
        avatar = teammateLarge.basic.avatar
        name = teammateLarge.basic.name.short
        text = teammateLarge.topic.originalPostText.sane
        unreadCount = teammateLarge.topic.unreadCount
        minutesSinceLast = teammateLarge.topic.minutesSinceLastPost
    }
    
    init?(remotePayload: RemotePayload) {
        switch remotePayload.type {
        case .privateMessage:
            self.id = remotePayload.userIDValue
            self.name = remotePayload.userNameValue
            self.avatar = remotePayload.avatar ?? ""
            self.text = remotePayload.messageValue
            self.unreadCount = 0
            self.minutesSinceLast = 0
        default:
            return nil
        }
    }
}
