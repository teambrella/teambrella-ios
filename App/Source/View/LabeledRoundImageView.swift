//
//  labeledRoundImageView.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 29.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit

@IBDesignable
class LabeledRoundImageView: UIView {
    @IBInspectable var textColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    @IBInspectable var labelBackgroundColor: UIColor = .blueWithAHintOfPurple
    @IBInspectable var riskLabelText: String = "" {
        didSet {
            riskLabel.text = riskLabelText
        }
    }
    
    lazy var avatar: RoundImageView = {
        let ava = RoundImageView()
        self.insertSubview(ava, at: 0)
        ava.clipsToBounds = true
        return ava
    }()
    lazy var riskLabel: Label = {
        let lbl = Label()
        self.addSubview(lbl)
        lbl.textAlignment = NSTextAlignment.center
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.clipsToBounds = true
        lbl.layer.cornerRadius = 3
        lbl.layer.borderWidth = 1
        lbl.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        lbl.textInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        riskLabel.frame = CGRect(x: 0,
                                 y: bounds.midY + bounds.midY / 2,
                                 width: bounds.width,
                                 height: bounds.height / 3)
        
        avatar.frame = CGRect(x: 0,
                              y: bounds.maxY - bounds.width - riskLabel.frame.height / 2,
                              width: bounds.width,
                              height: bounds.width)
       // avatar.image = #imageLiteral(resourceName: "cat")
        
        riskLabel.backgroundColor = labelBackgroundColor
        riskLabel.text = riskLabelText
        riskLabel.textColor = textColor
    }
    
}
