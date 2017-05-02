//
//  UIView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

fileprivate var activityIndicatorViewAssociativeKey = "ActivityIndicatorViewAssociativeKey"
public extension UIView {
    var  indicator: UIActivityIndicatorView {
        get {
            if let activityIndicatorView = getAssociatedObject(&activityIndicatorViewAssociativeKey)
                as? UIActivityIndicatorView {
                return activityIndicatorView
            } else {
                let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                activityIndicatorView.activityIndicatorViewStyle = .gray
                activityIndicatorView.color = .gray
                activityIndicatorView.center = center
                activityIndicatorView.hidesWhenStopped = true
                addSubview(activityIndicatorView)
                
                setAssociatedObject(activityIndicatorView,
                                    associativeKey: &activityIndicatorViewAssociativeKey,
                                    policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activityIndicatorView
            }
        }
        
        set {
            addSubview(newValue)
            setAssociatedObject(newValue,
                                associativeKey:&activityIndicatorViewAssociativeKey,
                                policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
