//
// Created by Yaroslav Pasternak on 07.04.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum MaritalStatus: Int {
    case unknown    = 0
    case single     = 1
    case divorced   = 2
    case widowed    = 9
    case married    = 10
}

extension MaritalStatus: Nameable {
    var name: String {
        let text: String!
        switch self {
        case .divorced:     text = "divorced"
        case .single:       text = "single"
        case .widowed:      text = "widowed"
        case .married:      text = "married"
        default:            text = "unknown"
        }
        return text
    }

    var localizableName: String {
        return "General.maritalStatus." + name
    }
}
