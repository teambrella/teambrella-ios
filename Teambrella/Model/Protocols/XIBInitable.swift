//
//  XIBInitable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
