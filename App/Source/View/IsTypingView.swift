//
//  IsTypingView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.09.17.
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
//

import UIKit

@IBDesignable
class IsTypingView: UIView {
    lazy var left: Dot = {
        let dot = Dot(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.addSubview(dot)
        return dot
    }()
    
    lazy var middle: Dot = {
        let dot = Dot(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.addSubview(dot)
        return dot
    }()
    
    lazy var right: Dot = {
        let dot = Dot(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.addSubview(dot)
        return dot
    }()
    
    lazy var views: [UIView] = { [self.left, self.middle, self.right] }()
    
    var currentIdx: Int = 0
    
    @IBInspectable var dotColor: UIColor = .black {
        didSet {
            views.forEach { $0.backgroundColor = dotColor }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        animate()
    }
    
    func animate() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            for (idx, view) in self.views.enumerated() {
                if idx == self.currentIdx {
                    view.transform = CGAffineTransform(translationX: 0, y: -5)
                } else {
                    view.transform = CGAffineTransform.identity
                }
            }
        }) { [weak self] completed in
            guard let `self` = self else { return }
            
            self.currentIdx = self.currentIdx < self.views.count ? self.currentIdx + 1 : 0
            if self.currentIdx == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.animate()
                }
            } else {
                self.animate()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        left.center = CGPoint(x: left.frame.width / 2, y: self.bounds.midY)
        middle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        right.center = CGPoint(x: self.bounds.width - left.frame.width / 2, y: self.bounds.midY)
    }
    
}

class Dot: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = frame.width / 2
    }
    
}
