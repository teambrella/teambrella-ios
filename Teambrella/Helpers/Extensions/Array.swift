//
//  Array.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

extension Array {
    /// Binary search could be applied to pre-sorted arrays only
    func insertionIndexOf(element: Element, order: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
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
