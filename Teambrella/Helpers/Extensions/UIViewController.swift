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
    
    func listenForKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIViewController.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        }
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        }
    }
    
    func keyboardWillChangeFrame(notification: Notification) {
        
    }
    
    /// simulates gradient on navigation bar
    func addGradientNavBar() {
        setupTransparentNavigationBar()
        defaultGradientOnTop()
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
        gradientView.bottomColor = .warmBlue
        gradientView.topColor = .frenchBlue
        view.addSubview(gradientView)
        var constraints: [NSLayoutConstraint] = []
        let views = ["gradientView": gradientView]
        let hConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[gradientView]-0-|",
            options: [],
            metrics: nil,
            views: views)
        constraints += hConstraints
        let vConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(0)-[gradientView(64)]",
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
