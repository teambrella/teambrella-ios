//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

class ChatVotingStatsCell: UICollectionViewCell {
    enum Constant {
        static let textInsetY: CGFloat = 8
        static let textInsetX: CGFloat = 8
        static let cloudCornerRadius: CGFloat = 6
        static let fontSize: CGFloat = 14
    }
    
    var cloudSize: CGSize = .zero
    
    var cloudColor: UIColor = .perrywinkle
    var borderColor: UIColor = .cornflowerBlueThree
    
    var id: String = ""
    var onTap: (() -> Void)?
    
    lazy var textLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = UIFont.teambrella(size: Constant.fontSize)
        view.numberOfLines = 0
        
        self.contentView.addSubview(view)
        return view
    }()
    
    var cloudFrame: CGRect {
        return CGRect(x: 0, y: 0, width: cloudSize.width, height: cloudSize.height)
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
        backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(tap)
    }
    
    @objc
    private func tapCell() {
        onTap?()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        prepareCloud(in: context)
    }
    
    func prepare(with model: ChatCellModel, size: CGSize) {
        cloudSize = size
        id = model.id
        setNeedsDisplay()
        
        switch model {
        case let textModel as ServiceMessageCellModel:
            setupViews(model: textModel)
        default:
            break
        }
    }
    
    private func prepareCloud(in context: CGContext) {
        let path = UIBezierPath(roundedRect: cloudFrame, cornerRadius: Constant.cloudCornerRadius)
        context.setFillColor(cloudColor.cgColor)
        context.setStrokeColor(borderColor.cgColor)
        context.addPath(path.cgPath)
        context.setLineWidth(1)
        context.drawPath(using: .fillStroke)
    }
    
    func setupViews(model: ServiceMessageCellModel) {
        textLabel.frame = CGRect(x: Constant.textInsetX,
                                 y: Constant.textInsetY,
                                 width: cloudSize.width - Constant.textInsetX * 2,
                                 height: cloudSize.height - Constant.textInsetY * 2)
        textLabel.text = model.text
        
    }
    
}
