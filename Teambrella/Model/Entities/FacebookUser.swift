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

struct FacebookUser {
    let name: String
    let firstName: String?
    let lastName: String?
    let gender: Gender
    let email: String?
    let minAge: Int
    let picture: String?
    
    init(dict: [String: Any]) {
        name = dict["name"] as? String ?? ""
        firstName = dict["first_name"] as? String
        lastName = dict["last_name"] as? String
        if let genderString = dict["gender"] as? String {
             gender = Gender.fromFacebook(string: genderString)
        } else {
            gender = .male
        }

        email = dict["email"] as? String
        var minAge = 0
        if let ageRange = dict["age_range"] as? [String: Any] {
            minAge = ageRange["min"] as? Int ?? 0
        }
        self.minAge = minAge
        if let pic = dict["picture"] as? [String: Any], let data = pic["data"] as? [String: Any] {
            picture = data["url"] as? String
        } else {
            picture = nil
        }
    }
    
}
