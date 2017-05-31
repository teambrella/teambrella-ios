//
//  UIFont.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

extension UIFont {
    // swiftlint:disable force_unwrapping
    static func teambrella(size: CGFloat) -> UIFont {
        return UIFont(name: "AkkuratPro-Regular", size: size)!
    }
    
    static func teambrellaBold(size: CGFloat) -> UIFont {
        return UIFont(name: "AkkuratPro-Bold", size: size)!
    }
}
