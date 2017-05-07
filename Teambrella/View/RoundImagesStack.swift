//
//  RoundImagesStack.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

/**
 Shows a horizontal stack of round images
 */
class RoundImagesStack: UIView {
    private var views: [RoundImageView] = []
    /// width of the limb around image view (image view changes it's size to fit into the limb)
    var limbWidth: CGFloat = 1
    var limbColor: UIColor = .white
    /// max images that could be contained in the view
    var maxImages: Int = 1
    var isEmpty: Bool {
        return views.isEmpty
    }
    
    /// Populate stack with images
    ///
    /// - Parameters:
    ///   - images: URLs of the images
    ///   - label: optional label to be shown as last view
    ///   - max: maximum quantity of images that can be added to this stack. If actual count of images is less than the
    ///          maximum count, images will be set to the left
    func  set(images: [URL], label: String? = nil, max: Int? = nil) {
        if let max = max {
            self.maxImages = max
        } else {
            self.maxImages = label == nil ? images.count : images.count + 1
        }
        views.forEach {
            $0.removeFromSuperview()
        }
        views.removeAll()
        images.forEach { url in
            let view = RoundImageView()
            view.kf.setImage(with: url)
            self.add(view: view)
        }
        if let label = label {
            let lastView = RoundImageView()
            lastView.viewColor = .gray
            lastView.text = label
            add(view: lastView)
        }
    }
    
    func add(view: RoundImageView) {
        if views.count < maxImages {
            views.append(view)
        } else {
            views.popLast().map { $0.removeFromSuperview() }
            views.append(view)
        }
        view.limbColor = limbColor
        view.inset = limbWidth
        addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !views.isEmpty else { return }
        
        let side = bounds.height
        let quantity = CGFloat(maxImages)
        let interval: CGFloat = quantity > 1 ? (bounds.width - side) / (quantity - 1) : 0
        let size = CGSize(width: side, height: side)
        for (idx, view) in views.enumerated() {
            view.frame.origin = CGPoint(x: CGFloat(idx) * interval,
                                        y: 0)
            view.frame.size = size
        }
    }
    
}
