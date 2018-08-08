//
//  ItemType.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.07.17.

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

enum ItemType: Int, Codable {
    case teammate = 0
    case claim = 1
    case rule = 2
    case teamChat = 3
    case teamNotification = 100
    case fundWallet = 200
    
    case privateChat = -10
}
