//
//  Decimal.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension Decimal {
    var double: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
