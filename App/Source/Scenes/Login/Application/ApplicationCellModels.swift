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
    let image: String
    let name: String
    let city: String
}

struct ApplicationTitleCellModel: ApplicationCellModel {
    let title: String
}

struct ApplicationInputCellModel: ApplicationCellModel {
    let text: String
    let headlightText: String
    let placeholderText: String
    var inputText: String
}

struct ApplicationActionCellModel: ApplicationCellModel {
    let buttonText: String
}

struct ApplicationInputDateCellModel: ApplicationCellModel {
    let text: String
    let placeholderText: String
    var date: Date?
}

class ApplicationUserData {
    var name: String?
    var birthday: Date?
    var location: String?
}

protocol ApplicationCellModel {
    
}

protocol ApplicationCell {
    func setup(with model: ApplicationCellModel)
}
