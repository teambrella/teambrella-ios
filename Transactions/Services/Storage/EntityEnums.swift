//
//  EntityEnums.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 18.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

public enum UserAddressStatus: Int {
    case previous = 0
    case current = 1
    case next = 2
    case archive = 3
    
    // extra values, that are valid for local DB only
    case invalid = 4
    case serverPrevious = 10
    case serverCurrent = 11
    case serverNext = 12
}
