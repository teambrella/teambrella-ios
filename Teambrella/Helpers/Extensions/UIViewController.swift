//
//  UIViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

extension UIViewController {
    func performSegue(type: SegueType, sender: Any? = nil) {
        performSegue(withIdentifier: type.rawValue, sender: sender)
    }
}
