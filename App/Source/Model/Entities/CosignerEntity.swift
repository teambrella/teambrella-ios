//
//  CosignerEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 17.07.17.

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

struct CosignerEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case avatar = "Avatar"
        case name = "Name"
        case userId = "UserId"
    }
    
    var avatar: Avatar
    var name: String
    var userId: String

}
