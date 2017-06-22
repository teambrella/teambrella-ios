//
//  PiecewiseFunction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 08.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

/*
 Кусочно линейная функция
 */
struct PiecewiseFunction {
    struct Item: Comparable {
        let x: Double
        let value: Double
        
        static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.x == rhs.x
        }
        
        static func < (lhs: Item, rhs: Item) -> Bool {
            return lhs.x < rhs.x
        }
    }
    
    private var items: [Item] = []
    var minValue: Double { return items.reduce(Double.greatestFiniteMagnitude) { min($0, $1.value) } }
    var maxValue: Double { return items.reduce(-Double.greatestFiniteMagnitude) { max($0, $1.value) } }
    
    init?(_ args: (Double, Double)...) {
        items = args.map { Item(x: $0.0, value: $0.1) }
        items.sort()
        
        // items entered should be unique
        if !items.isEmpty {
            var idx = items.count - 1
            while idx > 0 {
                if items[idx] == items[idx - 1] { return nil }
                idx -= 1
            }
        }
    }
    
    @discardableResult
    mutating func addPoint(x: Double, value: Double) -> Bool {
        for item in items where item.x == x { return false }
        items.insertOrdered(Item(x: x, value: value))
        return true
    }
    
    func value(at point: Double) -> Double? {
        let lesser: Item? = items.filter { $0.x < point }.last
        let larger: Item? = items.filter { $0.x > point }.first
        guard let less = lesser, let more = larger else { return nil }
        
        // (y-y1)/(y2-y1)=(x-x1)/(x2-x1)
        let y1 = less.value
        let y2 = more.value
        let x1 = less.x
        let x2 = more.x
        let x = point
        return y1 + (x - x1) / (x2 - x1) * (y2 - y1)
    }
    
}
