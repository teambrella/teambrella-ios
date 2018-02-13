//
//  UIView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.05.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import UIKit

private var activityIndicatorViewAssociativeKey = "ActivityIndicatorViewAssociativeKey"

extension UIView {
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
                                associativeKey: &activityIndicatorViewAssociativeKey,
                                policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        return nil
    }
    
    func contains(view: UIView) -> Bool {
        for subview in subviews {
            if subview.contains(view: view) {
                return true
            }
        }
        return false
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
