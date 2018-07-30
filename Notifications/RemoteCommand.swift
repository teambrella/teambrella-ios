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

enum RemoteCommandType: Int {
    case unknown = 0
    
    // will come only from Sockets
    case createdPost = 1
    case deletedPost = 2
    case typing = 3

    // may come from Push

    case newClaim = 4
    case privateMessage = 5
    case walletFunded = 6
    case postsSinceInteracted = 7
    case newTeammate = 8
    case newDiscussion = 9
    
    case topicMessage = 21

    case approvedTeammate = 35
}
