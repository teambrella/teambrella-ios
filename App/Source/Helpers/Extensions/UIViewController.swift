//
//  UIViewController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.05.17.

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

extension UIViewController {
    func performSegue(type: SegueType, sender: Any? = nil) {
        performSegue(withIdentifier: type.rawValue, sender: sender)
    }
    
    /// simulates gradient on navigation bar
    func addGradientNavBar() {
        setupTransparentNavigationBar()
        defaultGradientOnTop()
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7411764706, green: 0.7647058824, blue: 1, alpha: 1)
    }
    
    func setupTransparentNavigationBar() {
        guard let bar = navigationController?.navigationBar else { return }
        
        bar.barTintColor = .clear
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.shadowImage = UIImage()
    }
    
    func defaultGradientOnTop() {
        let gradientView = GradientView(frame: view.frame)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.bottomColor = .headerBlue
        gradientView.topColor = .headerBlue
        view.addSubview(gradientView)
        var constraints: [NSLayoutConstraint] = []
        let views = ["gradientView": gradientView]
        let hConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[gradientView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        constraints += hConstraints
        var navBarHeight:CGFloat = isIphoneX ? 88 : 64
        if #available(iOS 11.0, *) {
            //navBarHeight = view.safeAreaInsets.top
        }
        let verticalVisualFormat = "V:|-(0)-[gradientView(\(navBarHeight))]"
        let vConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: verticalVisualFormat,
            options: [],
            metrics: nil,
            views: views)
        constraints += vConstraints
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupDismissKeyboardOnTap() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
    }

    @objc
    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
