//
//  Routable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol Routable: class {
    static var storyboardName: String { get }
    static var ibName: String { get }
    
    static func instantiate() -> UIViewController
}

extension Routable where Self: UIViewController {
    static var storyboardName: String { return "Main" }
    static var ibName: String { return String(describing: type(of: self)) }
    
    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ibName)
    }
}
