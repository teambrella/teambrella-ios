//
//  ImageTransformer.swift
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

import UIKit

struct ImageTransformer {
    let image: UIImage
    
    var tabBarImage: UIImage? {
        let width: CGFloat = 25
        guard let circleMasked = circleMasked(limbWidth: 1,
                                              limbColor: .white) else { return nil }
        
        return ImageTransformer(image: circleMasked).resizeImage(newWidth: width)?.withRenderingMode(.alwaysOriginal)
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight),
                                               false,
                                               UIScreen.main.nativeScale)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func circleMasked(limbWidth: CGFloat, limbColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.squaredSize, false, UIScreen.main.nativeScale)
        defer { UIGraphicsEndImageContext() }
        let origin = CGPoint(x: image.isLandscape ? floor((image.size.width - image.size.height) / 2) : 0,
                             y: image.isPortrait  ? floor((image.size.height - image.size.width) / 2) : 0)
        guard let cgImage = image.cgImage?.cropping(to: CGRect(origin: origin,
                                                               size: image.squaredSize)) else { return nil }
        
        let path = UIBezierPath(ovalIn: image.squaredRect)
        path.addClip()
        UIImage(cgImage: cgImage).draw(in: image.squaredRect)
        
        limbColor.setStroke()
        path.lineWidth = limbWidth
        path.stroke()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
