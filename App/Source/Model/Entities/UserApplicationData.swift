//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import Foundation
import SwiftEmail

struct UserApplicationData {
    let teamID: Int
    let inviteCode: String?
    
    var name: String?
    var area: String?
    var emailString: String?
    var model: String?
    
    var email: EmailAddress? {
        guard let emailString = emailString else { return nil }

        return EmailAddress(string: emailString)
    }
    
    mutating func update(with string: String?, model: ApplicationInputCellModel) {
        switch model.type {
        case .city:
            area = string
        case .email:
            emailString = string
        case .item:
            self.model = string
        case .name:
        name = string
        }
    }
    
    func text(for model: ApplicationInputCellModel) -> String? {
        switch model.type {
        case .city:
            return area
        case .email:
           return emailString
        case .item:
            return self.model
        case .name:
            return name
        }
    }

}
