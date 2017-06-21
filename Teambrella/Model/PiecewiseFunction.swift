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
    struct Item {
        let x: Double
        let value: Double
    }
    
    private var items: [Item] = []
    var minValue: Double { return items.reduce(Double.greatestFiniteMagnitude) { $0 > $1.value ? $1.value : $0 } }
    var maxValue: Double { return items.reduce(-Double.greatestFiniteMagnitude) { $0 < $1.value ? $1.value : $0 } }
    
    init(_ args:(Double, Double)...) {
        items = args.map { Item(x: $0.0, value: $0.1) }
    }
    
    mutating func addPoint(x: Double, value: Double) {
        let item = Item(x: x, value: value)
        items.append(item)
        items.sort { $0.x < $1.x }
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
