//
//  TeamAccessLevel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.

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

enum TeamAccessLevel: Int, Codable {
    case noAccess                 = 0
    case hiddenDetailsAndEditMine = 1
    case readOnly                 = 2
    case readAllAndEditMine       = 3
    case full                     = 4
    case hiddenDetailsAndStealth  = -10
    case readOnlyAllAndStealth    = -20
}
