//
// Created by Yaroslav Pasternak on 10.04.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum TeammateType: Int, Decodable {
    case regular = 1
    case voter = 2

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        let type = TeammateType(rawValue: value) ?? .regular
        self = type
    }
}
