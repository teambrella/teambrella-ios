//
//  PiecewiseFunction.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 08.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct PiecewiseFunction {
    struct Item {
        let x: Double
        let value: Double
    }
    
    private var items: [Item] = []
    var minValue: Double { return items.reduce(Double.greatestFiniteMagnitude) { $0 > $1.value ? $1.value : $0 } }
    var maxValue: Double { return items.reduce(-Double.greatestFiniteMagnitude) { $0 < $1.value ? $1.value : $0 } }
    
    mutating func addPoint(x: Double, value: Double) {
        let item = Item(x: x, value: value)
        items.append(item)
        items.sort { $0.x < $1.x }
    }
    
    func value(at point: Double) -> Double? {
//        var lesser: Item?
//        var larger: Item?
        return nil
    }
    
}
