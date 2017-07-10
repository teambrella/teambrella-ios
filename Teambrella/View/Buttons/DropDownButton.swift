//
//  DropDownButton.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class DropDownButton: UIButton {
//    lazy var imageView: UIImageView = {
//        let imageView = UIImageView()
//        self.addSubview(imageView)
//        return imageView
//    }()
    
    lazy var dropDownView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "dropdown_arrow"))
        self.addSubview(imageView)
        return imageView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        dropDownView.center = CGPoint(x: bounds.maxX - dropDownView.frame.width / 2, y: bounds.midY)
    }
}
