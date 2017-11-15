//
/* Copyright(C) 2017 Teambrella, Inc.
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

@IBDesignable
class CloudView: UIView {
    struct Constant {
        static let tailWidth: CGFloat = 10
        static let tailHeight: CGFloat = 5
        static let cloudCornerRadius: CGFloat = 5
    }

    var rightPeekOffset: CGFloat = 0
    //@IBInspectable var rightTailOffset: CGFloat = 10
    @IBInspectable var fillColor: UIColor = UIColor.perrywinkle
    @IBInspectable var strokeColor: UIColor = UIColor.perrywinkle
    @IBInspectable var textColor: UIColor = .white
    var font: UIFont = UIFont.teambrellaBold(size: 10)
    var textAlignment: NSTextAlignment = .center
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
            setNeedsDisplay()
        }
    }
    
    lazy var titleLabel: Label = {
        let label = Label()
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        label.font = font
        label.textColor = textColor
        self.addSubview(label)
        
        label.leftInset = 12
        label.rightInset = 12
        label.topInset = 6
        label.bottomInset = 6
        
        // add constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: Constant.tailHeight).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return label
    }()
    
    //swiftlint:disable function_body_length
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var newPoint = CGPoint(x: titleLabel.frame.minX + Constant.cloudCornerRadius, y: titleLabel.frame.maxY)
        context.move(to: newPoint)
        newPoint.x = titleLabel.frame.minX
        newPoint.y = titleLabel.frame.maxY - Constant.cloudCornerRadius
        var controlP = CGPoint(x: titleLabel.frame.minX, y: titleLabel.frame.maxY)
        context.addQuadCurve(to: newPoint, control: controlP)
        
        newPoint.y = titleLabel.frame.minY + Constant.cloudCornerRadius
        context.addLine(to: newPoint)
        newPoint.x = titleLabel.frame.minX + Constant.cloudCornerRadius
        newPoint.y = titleLabel.frame.minY
        controlP = CGPoint(x: titleLabel.frame.minX, y: titleLabel.frame.minY)
        context.addQuadCurve(to: newPoint, control: controlP)
        
        newPoint.x = titleLabel.frame.maxX - rightPeekOffset - Constant.tailWidth / 2
        context.addLine(to: newPoint)

        newPoint.x += Constant.tailWidth / 2
        newPoint.y -= Constant.tailHeight
        context.addLine(to: newPoint)
        
        newPoint.x += Constant.tailWidth / 2
        newPoint.y = titleLabel.frame.minY
        context.addLine(to: newPoint)
        
        newPoint.x = titleLabel.frame.maxX - Constant.cloudCornerRadius
        context.addLine(to: newPoint)
        newPoint.x = titleLabel.frame.maxX
        newPoint.y = titleLabel.frame.minY + Constant.cloudCornerRadius
        
        controlP = CGPoint(x: titleLabel.frame.maxX, y: titleLabel.frame.minY)
        context.addQuadCurve(to: newPoint, control: controlP)
        
        newPoint.y = titleLabel.frame.maxY - Constant.cloudCornerRadius
        context.addLine(to: newPoint)
        newPoint.x = titleLabel.frame.maxX - Constant.cloudCornerRadius
        newPoint.y = titleLabel.frame.maxY
        
        controlP = CGPoint(x: titleLabel.frame.maxX, y: titleLabel.frame.maxY)
        context.addQuadCurve(to: newPoint, control: controlP)
        
        newPoint.x = titleLabel.frame.minX + Constant.cloudCornerRadius
        context.addLine(to: newPoint)
        
        context.closePath()
        
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        
        context.setLineWidth(1)
        context.drawPath(using: .fillStroke)
    }
    
    func appear() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = 1
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.alpha = 0
        }) { finished in
            completion()
        }
    }
    
}
