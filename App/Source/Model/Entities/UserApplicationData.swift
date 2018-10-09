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

class UserApplicationData: Codable {
    var teamID: Int?
    var inviteCode: String?
    
    var name: String?
    var location: String?
    var emailString: String?
    var model: String?
    
    var gender: Gender?
    var subType: String?
    var year: Int?
    var price: Decimal?
    var spayed: Bool?
    var photos: [String]?
    var message: String?
    
    var email: EmailAddress? {
        guard let emailString = emailString else { return nil }

        return EmailAddress(string: emailString)
    }
    
    init(welcome: WelcomeEntity) {
        teamID = welcome.teamID
        name = welcome.nameTo?.entire
        location = welcome.location
        emailString = welcome.email
    }
    
    func update(with string: String?, model: ApplicationInputCellModel) {
        switch model.type {
        case .city:
            location = string
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
            return location
        case .email:
           return emailString
        case .item:
            return self.model
        case .name:
            return name
        }
    }

    func validate(model: ApplicationInputCellModel) -> Bool {
        switch model.type {
        case .city:
            if let location = location, location.count > 1 {
                return true
            }
        case .email:
            if let emailString = emailString, EmailAddress(string: emailString) != nil {
                return true
            }
        case .item:
            if let model = self.model, model.count > 1 {
                return true
            }
        case .name:
            if let name = name, name.count > 1 {
                return true
            }
        }
        return false
    }
    
    enum CodingKeys: String, CodingKey {
        case teamID = "teamId"
        case inviteCode = "invite"
        case name = "Name"
        case location = "Location"
        case emailString = "Email"
        case model = "CarModelString"
        
        case gender = "Gender"
        case subType = "SubType"
        case year = "Year"
        case price = "Price"
        case spayed = "Spayed"
        case photos = "Photos"
        case message = "Message"
    }

}
