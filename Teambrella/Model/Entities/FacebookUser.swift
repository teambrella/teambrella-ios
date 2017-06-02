//
//  FacebookUser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
