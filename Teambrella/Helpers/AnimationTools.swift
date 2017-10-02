//
//  AnimationTools.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.10.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct AnimationTools {
    static func rotation(y angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func perspectiveTransform(for view: UIView, value: CGFloat = -0.002) {
        var transform = CATransform3DIdentity
        transform.m34 = value
        view.layer.sublayerTransform = transform
    }
}
