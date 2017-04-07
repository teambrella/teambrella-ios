//
// Created by Yaroslav Pasternak on 07.04.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum ClamState: Int {
    case voting     = 0
    case revoting   = 1
    case declined   = 2
    case inPayment  = 3
    case processed  = 4
}

extension ClamState: Nameable {
    var name: String {
        let text: String!
        switch self {
        case .voting:       text = "voting"
        case .revoting:     text = "revoting"
        case .declined:     text = "declined"
        case .inPayment:    text = "inPayment"
        case .processed:    text = "processed"
        }
        return text
    }

    var localizableName: String {
        return "general.claimState." + name
    }
}
