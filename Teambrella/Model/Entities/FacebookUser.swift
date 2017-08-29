//
//  FacebookUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.06.17.

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
import SwiftyJSON

struct FacebookUser {
    let name: String
    let firstName: String?
    let lastName: String?
    let gender: Gender
    let email: String?
    let minAge: Int
    let picture: String?
    
    init(dict: [String: Any]) {
        let json = JSON(dict)
        name = json["name"].stringValue
        firstName = json["first_name"].string
        lastName = json["last_name"].string
        gender = Gender.fromFacebook(string: json["gender"].stringValue)
        email = json["email"].string
        minAge = json["age_range"]["min"].intValue
        picture = json["picture"]["data"]["url"].string
    }
    
}
