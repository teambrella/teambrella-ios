//
//  HelperGlobalFunctions.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 03.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum DeviceType: Int {
    case small = 320
    case normal = 375
    case large = 414
}

var deviceType: DeviceType {
    let screenWidth = UIScreen.main.bounds.width
    return DeviceType(rawValue: Int(screenWidth)) ?? .small
}

var isSmallIPhone: Bool { return deviceType == .small }
