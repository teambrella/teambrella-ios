//
//  TopicEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.04.17.

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

struct TopicEntity: Decodable {
    let id: String
    
    let originalPostText: SaneText
    let topPosterAvatars: [String]
    let posterCount: Int
    var unreadCount: Int
    var minutesSinceLastPost: Int
    
    var description: String {
        return "TopicEntity id: \(id)"
    }

    init(id: String) {
        self.id = id
        originalPostText = SaneText.empty
        topPosterAvatars = []
        posterCount = 0
        unreadCount = 0
        minutesSinceLastPost = 0
    }

    enum CodingKeys: String, CodingKey {
        case id = "TopicId"
        case originalPostText = "OriginalPostText"
        case topPosterAvatars = "TopPosterAvatars"
        case posterCount = "PosterCount"
        case unreadCount = "UnreadCount"
        case minutesSinceLastPost = "SinceLastPostMinutes"
    }
}
