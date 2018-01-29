//
//  Random.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.04.17.

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

/// Generates random numbers
struct Random {
    /// Integer random in range from value included to value excluded
    static func range(from: Int = 0, to: Int) -> Int {
        guard from < to else {
            log("Random range where from is larger than to. Return lowest value", type: .info)
            return to
        }
        
        var offset = 0
        if from < 0 {
            offset = abs(from)
        }
        
        let mini = UInt32(from + offset)
        let maxi = UInt32(to + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
    
    static var bool: Bool { return range(from: 0, to: 2) > 0 ? true : false }
}
