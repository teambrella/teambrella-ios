//
//  UIImageView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    func showAvatar(string: String) {
        let modified = service.server.avatarURLstring(for: string)
        guard let url = URL(string: modified) else { return }
        
        showAvatar(url: url)
    }
    
    func showAvatar(url: URL) {
        kf.setImage(with: url)
    }
    
    func showImage(url: URL, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = service.server.key
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            
            self?.kf.setImage(with:url, placeholder: nil, options: [.requestModifier(modifier)],
                              progressBlock: nil,
                              completionHandler: { image, error, _, _ in
                                completion?(image, error)
            })
        }
    }
    
    func showImage(string: String, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        guard let url = service.server.url(string: string) else { return }
        
        showImage(url: url, completion: completion)
    }
}
