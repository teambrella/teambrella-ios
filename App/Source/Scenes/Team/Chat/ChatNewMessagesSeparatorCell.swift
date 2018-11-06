//
//  ChatNewMessagesSeparatorCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.09.2017.
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

class ChatNewMessagesSeparatorCell: UICollectionViewCell {
    lazy var label: Label = {
        let label = Label()
        label.font = UIFont.teambrellaBold(size: 10)
        label.textAlignment = .center
        label.textColor = self.color
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)

        let superview = self.contentView
        label.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        return label
    }()

    var color: UIColor = UIColor.darkTextColor
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented for \(#file)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setNeedsUpdateConstraints()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        prepareCloud(in: context)
    }

    private func prepareCloud(in context: CGContext) {
        let startingPoint = CGPoint(x: 0, y: 0)
        let wdt = frame.width
        let hgt = frame.height
        var pen: CGPoint = startingPoint
        context.move(to: pen)
        pen.x += wdt
        context.addLine(to: pen)
        pen.y += hgt
        context.move(to: pen)
        pen.x -= wdt
        context.addLine(to: pen)

        context.setLineWidth(1)
        context.setStrokeColor(UIColor.lightBlueGray.cgColor)
        context.strokePath()
    }
    
}
