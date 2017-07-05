//
//  Math.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

func isInRange<T: Comparable>(item: T, min: T, max: T) -> Bool {
    return item >= min && item <= max
}

func log(base: Double, value: Double) -> Double {
    return log(value) / log(base)
}
