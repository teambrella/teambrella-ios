//
//  LabeledButton.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.07.17.

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

class LabeledButton: UIButton {
    var cornerText: String? {
        didSet {
            cornerLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 16)
            cornerLabel.text = cornerText
            cornerLabel.sizeToFit()
            // to maintain round shape
            cornerLabel.frame.size.width = max(cornerLabel.frame.width, cornerLabel.frame.height)
            cornerLabel.isHidden = cornerText == nil
        }
    }
    
    var cornerDot: Bool? {
        didSet {
            cornerDotView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            cornerDotView.isHidden = !(cornerDot ?? false)
            cornerDotView.center = CGPoint(x: bounds.maxX - cornerDotView.frame.width / 2, y: cornerDotView.frame.height / 2)
        }
    }
    
    lazy var cornerLabel: Label = {
        let label = Label(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        label.font = UIFont.teambrellaBold(size: 10)
        label.textAlignment = .center
        label.textInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
        label.textColor = .white
        label.layer.cornerRadius = 16.0 / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.headerBlue.cgColor
        label.layer.borderWidth = 1.5
        label.backgroundColor = .tealish
        self.addSubview(label)
        return label
    }()

    lazy var cornerDotView: Label = {
        let labelInner = Label(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        labelInner.layer.cornerRadius = 6.0 / 2
        labelInner.layer.masksToBounds = true
        labelInner.layer.borderWidth = 0
        labelInner.backgroundColor = .tealish

        let label = Label(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.layer.cornerRadius = 10.0 / 2
        label.layer.masksToBounds = true
        label.backgroundColor = .headerBlue
        label.addSubview(labelInner)
        labelInner.center = CGPoint(x: 5, y: 5)
        self.addSubview(label)
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        if cornerText != nil {
            cornerLabel.center = CGPoint(x: bounds.maxX - cornerLabel.frame.width / 2, y: cornerLabel.frame.height / 2)
        }
    }
    
}
