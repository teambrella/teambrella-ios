//
//  UIImageView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

import Foundation
import Kingfisher

extension UIImageView {
    func setStandardPlaceholder() {
        image = #imageLiteral(resourceName: "imagePlaceholder")
    }
    
    func show(_ avatar: Avatar,
              options: KingfisherOptionsInfo? = nil,
              isFullSize: Bool = false,
              completion: ((UIImage?, NSError?) -> Void)? = nil) {
        guard let url = avatar.url else { return }

        self.image = nil
        showAvatar(url: url, options: options, completion: completion)
        
    }
    
    func show(_ image: Photo,
              needHeaders: Bool = true,
              completion: ((UIImage?, NSError?) -> Void)? = nil) {
        self.image = nil
        showImage(string: image.string, needHeaders: needHeaders, completion: completion)
    }
    
    func showAvatar(url: URL,
                    options: KingfisherOptionsInfo? = nil,
                    completion: ((UIImage?, NSError?) -> Void)? = nil) {
        kf.setImage(with: url,
                    placeholder: nil,
                    options: options)
//                    ,
//                    progressBlock: nil,
//                    completionHandler: { image, error, _, _ in
//                        completion?(image, error)
//        })
    }
    
    func showImage(url: URL, needHeaders: Bool, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        if needHeaders {
        service.dao.freshKey { [weak self] key in
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            
            self?.kf.setImage(with: url,
                              placeholder: nil,
                              options: [.requestModifier(modifier)]
//                ,
//                              progressBlock: nil,
//                              completionHandler: { image, error, _, _ in
//                                completion?(image, error)
//            }
            )
        }
        } else {
            self.kf.setImage(with: url,
                              placeholder: nil,
                              options: []
//                ,
//                              progressBlock: nil,
//                              completionHandler: { image, error, _, _ in
//                                completion?(image, error)
//            }
            )
        }
    }
    
    func showImage(string: String?, needHeaders: Bool, completion: ((UIImage?, NSError?) -> Void)? = nil) {
        guard let string = string else { return }
        guard let url = URLBuilder().url(string: string) else { return }
        
        showImage(url: url, needHeaders: needHeaders, completion: completion)
    }
}
