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
    
    func present(imageString: String) {
        mainImageString = imageString
        inputs(from: [imageString]) { [weak self] inputs in
            self?.setImageInputs(inputs)
            self?.contentScaleMode = .scaleAspectFill
        }
    }
    
    func present(avatarString: String) {
        mainImageString = avatarString
        inputs(from: [avatarString]) { [weak self] inputs in
            self?.setImageInputs(inputs)
            self?.contentScaleMode = .scaleAspectFill
        }
    }
    
    func inputs(from imageStrings: [String], completion: @escaping ([InputSource]) -> Void) {
        let imageStrings = imageStrings.map { service.server.urlString(string: $0) }
        service.storage.freshKey { key in
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            
            let inputs: [InputSource] = imageStrings.flatMap { KingfisherSource(urlString: $0,
                                                                                options: [.requestModifier(modifier)])
                
            }
            completion(inputs)
        }
    }
    
    @objc
    func tap(sender: UITapGestureRecognizer ) {
        onTap?(self)
    }
    
    func fullscreen(in controller: UIViewController?, imageStrings: [String]?) {
        guard let controller = controller else { return }
        guard let imageStrings = imageStrings else {
            self.presentFullScreenController(from: controller)
            return
        }
        
        inputs(from: imageStrings, completion: { [weak self] inputs in
            guard let `self` = self else { return }
            
            self.setImageInputs(inputs)
            if let mainImageString = self.mainImageString,
                let page = imageStrings.index(of: mainImageString) {
                self.setCurrentPage(page, animated: false)
                let vc = self.presentFullScreenController(from: controller)
                vc.closeButton.frame = CGRect(x: controller.view.bounds.width - 44, y: 20, width: 44, height: 44)
                vc.closeButton.setImage(#imageLiteral(resourceName: "crossIcon"), for: .normal)
                vc.zoomEnabled = true
            }
        })
    }
    
}
