//
// Created by Yaroslav Pasternak on 07.04.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum ClaimState: Int, Decodable {
    case voting     = 0
    case revoting   = 10
    case voted      = 15
    case declined   = 20
    case inPayment  = 30
    case processed  = 40
    
    init(decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = ClaimState(rawValue: value) ?? .voting
    }
}

extension ClaimState: Nameable {
    var name: String {
        let text: String!
        switch self {
        case .voting:       text = "voting"
        case .revoting:     text = "revoting"
        case .voted:        text = "voted"
        case .declined:     text = "declined"
        case .inPayment:    text = "inPayment"
        case .processed:    text = "processed"
        }
        return text
    }

    var localizableName: String {
        return "General.claimState." + name
    }
}
