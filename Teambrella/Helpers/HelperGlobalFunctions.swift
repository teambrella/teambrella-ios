//
//  HelperGlobalFunctions.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 03.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

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
var isIphoneX: Bool { return deviceType == .normal && UIScreen.main.bounds.height >= 812 }
