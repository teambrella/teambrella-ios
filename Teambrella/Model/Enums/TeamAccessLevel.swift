//
//  TeamAccessLevel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum TeamAccessLevel: Int {
    case noAccess                 = 0
    case hiddenDetailsAndEditMine = 1
    case readOnly                 = 2
    case readAllAndEditMine       = 3
    case full                     = 4
}
