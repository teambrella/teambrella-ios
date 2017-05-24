//
//  UIStoryboardSegue.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

extension UIStoryboardSegue {
    var type: SegueType { return identifier.flatMap { SegueType(rawValue: $0) } ?? .unknown }
}
