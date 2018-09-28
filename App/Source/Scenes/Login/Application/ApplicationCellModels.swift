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

struct ApplicationHeaderCellModel: ApplicationCellModel {
    let identifier: ApplicationCellIdentifier = .header
    let image: String
    let name: String
    let city: String
}

struct ApplicationTitleCellModel: ApplicationCellModel {
    let identifier: ApplicationCellIdentifier = .title
    let title: String
}

struct ApplicationInputCellModel: ApplicationCellModel {
    enum InputType {
        case name, item, city, email
    }
    
    let identifier: ApplicationCellIdentifier = .input
    let type: InputType
    let text: String
    let headlightText: String
    let placeholderText: String
}

struct ApplicationTermsAndConditionsCellModel: ApplicationCellModel {
    let identifier: ApplicationCellIdentifier = .termsAndConditions
    let format: String
    let linkText: String
    let link: String
    var text: NSAttributedString {
        return format.localized(linkText).link(substring: linkText, urlString: link)
    }
}

struct ApplicationActionCellModel: ApplicationCellModel {
    let identifier: ApplicationCellIdentifier = .action
    let buttonText: String
}

//struct ApplicationInputDateCellModel: ApplicationCellModel {
//    let identifier: ApplicationCellIdentifier =
//    let text: String
//    let placeholderText: String
//    var date: Date?
//}

enum ApplicationCellIdentifier: String {
    case header, title, input, termsAndConditions, action
}

protocol ApplicationCellModel {
    var identifier: ApplicationCellIdentifier { get }
}

protocol ApplicationCell {
    func setup(with model: ApplicationCellModel, userData: UserApplicationData)
}
