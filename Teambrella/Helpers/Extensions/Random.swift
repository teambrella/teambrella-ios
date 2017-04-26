//
//  Random.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

/// Generates random numbers
struct Random {
    /// Integer random in range from value included to value excluded
    static func range(from: Int = 0, to: Int) -> Int {
        guard from < to else {
            print("Random range where from is larger than to. Return lowest value")
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
    
}
