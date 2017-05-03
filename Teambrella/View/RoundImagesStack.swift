//
//  RoundImagesStack.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

class RoundImagesStack: UIView {
    var views: [RoundImageView] = []
    var limbWidth: CGFloat = 1
    var limbColor: UIColor = .white
    var isEmpty: Bool {
        return views.isEmpty
    }
    
    func  set(images: [URL], label: String? = nil) {
        views.forEach {
            $0.removeFromSuperview()
        }
        views.removeAll()
        images.forEach { url in
            let view = RoundImageView()
            view.kf.setImage(with: url)
            self.views.append(view)
        }
        if let label = label {
            let lastView = RoundImageView()
            lastView.viewColor = .gray
            lastView.text = label
            self.views.append(lastView)
        }
        views.forEach {
            $0.limbColor = self.limbColor
            $0.inset = self.limbWidth
            self.addSubview($0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let side = bounds.height
        let interval: CGFloat = (bounds.width - bounds.height) / CGFloat(views.count)
        let size = CGSize(width: side, height: side)
        let offset = side / 2
        for (idx, view) in views.enumerated() {
            view.frame.size = size
            view.center = CGPoint(x: offset + interval * CGFloat(idx),
                                  y: bounds.midY)
        }
    }
    
}
