//
//  Array.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension Array {
    /// Binary search could be applied to pre-sorted arrays only
    func insertionIndexOf(element: Element, order: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if order(self[mid], element) {
                lo = mid + 1
            } else if order(element, self[mid]) {
                hi = mid - 1
            } else {
                return mid
            }
        }
        return lo
    }
}

extension  Array where Element: Comparable {
    /// Use only on pre-sorted array
    mutating func insertOrdered(_ element: Element) {
        insert(element, at: insertionIndexOf(element: element, order: { $0 < $1 }))
    }
}
