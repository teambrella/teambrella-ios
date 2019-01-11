//
//  SocketCommand.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.09.17.
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

enum SocketCommand: Int {
    case auth           = 0
    case newPost        = 1

    case meTyping       = 3

    case privateMessage = 5
    
    case theyTyping     = 13
    
    case notifyPosted   = 21

    case dbDump         = 101
    /*

    case deletePost     = 2

    case newClaim       = 4

    case walletFunded   = 6
    case newMessages    = 7
    case newTeammate    = 8
    case newTeammates   = 9
    */

}
