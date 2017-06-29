//
//  UIImage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

extension UIImage {
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return !isPortrait }
    var squaredSide: CGFloat { return min(size.width, size.height) }
    var squaredSize: CGSize { return CGSize(width: squaredSide, height: squaredSide) }
    var squaredRect: CGRect { return CGRect(origin: .zero, size: squaredSize) }
}
