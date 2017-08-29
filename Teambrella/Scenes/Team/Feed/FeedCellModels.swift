//
//  FeedCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

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

enum FeedCellType {
    case teammate, claim, topic
}

struct FeedCellModel {
    let title: String
    let text: String
    let avatar: String
    let teammatesAvatars: [String]
    let teammatesCount: Int
    let lastPostedMinutes: Int
    let unreadCount: Int
    let type: FeedCellType
    
    static var fake: FeedCellModel {
        return FeedCellModel(title: "Fake Discount Deals",
                                     text: "Just discovered a new garage in my neigborhood that is really good and...",
                                     avatar: "",
                                     teammatesAvatars: [],
                                     teammatesCount: 3,
                                     lastPostedMinutes: 1,
                                     unreadCount: 4,
                                     type: .teammate)
    }
}
