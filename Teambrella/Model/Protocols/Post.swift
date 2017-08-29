//
//  Post.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.04.17.

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

protocol Post: EntityLike {
    var postContent: String { get }
    var dateCreated: Date { get }
    var upvotesCount: Int { get }
    var downvotesCount: Int { get }
    var myVote: Int { get }
    var dateEdited: Date { get }
    var isSolution: Bool { get }
    var isTopicStarter: Bool { get }
    var isSpam: Bool { get }
    var ipAddress: String { get }
    var isPending: Bool { get }
    var userID: String { get }
}
