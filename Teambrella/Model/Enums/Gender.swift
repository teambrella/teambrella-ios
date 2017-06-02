//
//  Gender.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum Gender {
    case male
    case female
    
    static func fromFacebook(string: String) -> Gender {
        return string == "female" ? .female : .male
    }
}
