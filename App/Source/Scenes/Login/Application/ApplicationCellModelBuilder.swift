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

class ApplicationCellModelBuilder {
    func carGroupModels() -> [ApplicationCellModel] {
        return [  ApplicationTitleCellModel(title: "Login.Application.User.Title".localized),
                  ApplicationInputCellModel(type: .name,
                                            text: "Login.Application.Name.Title".localized,
                                            headlightText: "",
                                            placeholderText: "Login.Application.Name.Placeholder".localized),
                  ApplicationInputCellModel(type: .email,
                                            text: "Login.Application.Email.Title".localized,
                                            headlightText: "",
                                            placeholderText: "Login.Application.Email.Placeholder".localized),
                  ApplicationInputCellModel(type: .city,
                                            text: "Login.Application.City.Title".localized,
                                            headlightText: "",
                                            placeholderText: "Login.Application.City.Placeholder".localized),
                  ApplicationInputCellModel(type: .item,
                                            text: "Login.Application.Item.Title".localized,
                                            headlightText: "",
                                            placeholderText: "Login.Application.Item.Placeholder".localized),
                  ApplicationTermsAndConditionsCellModel(format: "Login.Application.TermsAndConditions.format",
                                                         linkText: "Login.Application.TermsAndConditions.Link".localized,
                                                         link: "https://teambrella.com/TermsOfService.pdf"),
                  ApplicationActionCellModel(buttonText: "Login.Application.RegisteerButton.Title".localized)
        ]
    }
    
    /*
     func titleModel(screenType: ApplicationScreenType) -> ApplicationTitleCellModel {
     switch screenType {
     case .user:
     return ApplicationTitleCellModel(title: "Login.Application.User.Title".localized)
     }
     }
     
     func inputModel(inputType: ApplicationInputCellType, userData: ApplicationUserData) -> ApplicationInputCellModel {
     let headlightText = "*"
     
     switch inputType {
     case .name:
     return ApplicationInputCellModel(text: "Login.Application.Name".localized,
     headlightText: headlightText,
     placeholderText: "", inputText: "")
     }
     }
     */
}
