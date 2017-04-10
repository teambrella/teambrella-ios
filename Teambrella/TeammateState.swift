//
// Created by Yaroslav Pasternak on 10.04.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum TeammateState: Int {
    case joinVoting = 0
    case joinDeclinedCanRevote = 1
    case joinOKcanRevote = 2
    case joinDeclinedCannotRevote = 3
    case joinOKcannotRevote = 4
    case joinRevoting = 5
    case normal = 6
    case revoting = 7
    case revotingResults = 8
}
