//
//  Mirror.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension Mirror {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        children.forEach { child in child.label.map { label in dict[label] = child.value } }
        return dict
    }
}
