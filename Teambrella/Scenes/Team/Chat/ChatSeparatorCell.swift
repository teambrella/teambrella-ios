//
//  ChatSeparatorCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ChatSeparatorCell: UICollectionViewCell {
    lazy var timeLabel: Label = {
        let label = Label()
        label.textAlignment = .center
        label.font = UIFont.teambrella(size: 14)
        label.textInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        label.backgroundColor = UIColor.charcoalGray.withAlphaComponent(0.25)
        label.textColor = .white
        self.contentView.addSubview(label)
        return label
    }()
    
    var text: String? {
        get {
            return timeLabel.text
        }
        set {
            guard timeLabel.text != newValue else { return }
            
            timeLabel.frame = self.bounds
            timeLabel.text = newValue
            timeLabel.sizeToFit()
            timeLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
            timeLabel.cornerRadius = timeLabel.frame.height / 2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) Not implemented")
    }
    
}
