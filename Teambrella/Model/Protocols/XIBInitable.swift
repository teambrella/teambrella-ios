//
//  XIBInitable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.

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

protocol XIBInitable: class {
    /// view that is instantiated from xib and stretches to the view adopting this protocol
    var contentView: UIView! { get set }
    /// name of swift file should be the same as xib name
    var nibName: String { get }
    /// should be called from init to setup view from xib
    func xibSetup()
    /// loads view from xib
    func loadViewFromNib() -> UIView?
}

extension XIBInitable where Self: UIView {
    var nibName: String { return String(describing: type(of: self)) }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(contentView)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
}
