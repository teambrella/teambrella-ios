//
//  GalleryView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import ImageSlideshow
import Kingfisher
import UIKit

class GalleryView: ImageSlideshow {
    var onTap: ( (GalleryView) -> Void )?
    
    var mainImageString: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(gestureRecognizer)
        isUserInteractionEnabled = true
    }
    
    func showImage(string: String) {
        galleryWith(imageStrings: [string])
    }
    
    func galleryWith(imageStrings: [String]) {
        if imageStrings.count == 1 {
            mainImageString = imageStrings.first
        }
        let imageStrings = imageStrings.flatMap { service.server.urlString(string: $0) }
        service.storage.freshKey { [weak self] key in
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            
            let inputs: [InputSource] = imageStrings.flatMap { KingfisherSource(urlString: $0,
                                                                                options: [.requestModifier(modifier)]) }
            self?.setImageInputs(inputs)
            self?.contentScaleMode = .scaleAspectFill
        }
    }
    
    func tap(sender: UITapGestureRecognizer ) {
        onTap?(self)
    }
    
    func fullscreen(in controller: UIViewController?, imageStrings: [String]?) {
        guard let controller = controller else { return }
        
        if let imageStrings = imageStrings,
            let mainImageString = mainImageString,
            let page = imageStrings.index(of: mainImageString) {
            galleryWith(imageStrings: imageStrings)
            setCurrentPage(page, animated: false)
        }
        
        presentFullScreenController(from: controller)
    }
    
}
