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
            cornerLabel.text = cornerText
            cornerLabel.isHidden = cornerText == nil
        }
    }
    
    lazy var cornerLabel: Label = {
        let label = Label(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        label.font = UIFont.teambrellaBold(size: 10)
        label.textAlignment = .center
        label.textInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
        label.textColor = .white
        label.layer.cornerRadius = 15 / 2
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.blueWithAHintOfPurple.cgColor
        label.layer.borderWidth = 1
        label.backgroundColor = .tealish
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
