//
//  Operators.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

infix operator &&=: AssignmentPrecedence

func &&= (left: Bool, right: Bool) -> Bool {
    return left && right
}
