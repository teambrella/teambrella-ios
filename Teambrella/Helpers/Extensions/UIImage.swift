//
//  UIImage.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.06.17.

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

import Kingfisher
import UIKit

extension UIImage {
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return !isPortrait }
    var squaredSide: CGFloat { return min(size.width, size.height) }
    var squaredSize: CGSize { return CGSize(width: squaredSide, height: squaredSide) }
    var squaredRect: CGRect { return CGRect(origin: .zero, size: squaredSize) }
}

extension UIImage {
    
    static func fetchAvatar(string: String,
                            width: CGFloat? = nil,
                            cornerRadius: CGFloat? = nil,
                            completion: @escaping (UIImage?, NSError?) -> Void) {
        let modified: String!
        if let width = width {
            modified = service.server.avatarURLstring(for: string, width: width * UIScreen.main.nativeScale)
        } else {
            modified = service.server.avatarURLstring(for: string)
        }
        guard let url = URL(string: modified) else { return }
        
        var options: KingfisherOptionsInfo? = []
        if let cornerRadius = cornerRadius {
            let processor = RoundCornerImageProcessor(cornerRadius: cornerRadius * UIScreen.main.nativeScale)
            options?.append(.processor(processor))
        }
        fetchAvatar(url: url, options: options, completion: completion)
    }
    
    static func fetchAvatar(url: URL,
                            options: KingfisherOptionsInfo? = nil,
                            completion: @escaping (UIImage?, NSError?) -> Void) {
        ImageDownloader.default.downloadImage(with: url, options: options) { image, error, url, data in
            completion(image, error)
        }
    }
    
    static func fetchImage(url: URL, completion: @escaping (UIImage?, NSError?) -> Void) {
        service.server.updateTimestamp { timestamp, error in
            let key = service.server.key
            let modifier = AnyModifier { request in
                var request = request
                request.addValue("\(key.timestamp)", forHTTPHeaderField: "t")
                request.addValue(key.publicKey, forHTTPHeaderField: "key")
                request.addValue(key.signature, forHTTPHeaderField: "sig")
                return request
            }
            
            ImageDownloader.default.downloadImage(with: url,
                                                  retrieveImageTask: nil,
                                                  options: [.requestModifier(modifier)],
                                                  progressBlock: nil,
                                                  completionHandler: { image, error, url, data in
                                                    completion(image, error)
            })
        }
    }
    
    static func fetchImage(string: String, completion: @escaping (UIImage?, NSError?) -> Void) {
        guard let url = service.server.url(string: string) else { return }
        
        fetchImage(url: url, completion: completion)
    }
}
