//
//  ChatFragmentParser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
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
//

import UIKit

enum ChatFragment {
    case text(SaneText)
    case image(urlString: String, urlStringSmall: String, aspect: CGFloat)
    
    static func imageFragment(image: UIImage, urlString: String, urlStringSmall: String) -> ChatFragment {
        let aspect = image.size.width / image.size.height
        return ChatFragment.image(urlString: urlString, urlStringSmall: urlStringSmall, aspect: aspect)
    }
    
    static func textFragment(string: String) -> ChatFragment {
        return ChatFragment.text(SaneText(text: string))
    }
}

struct ChatFragmentParser {
    var defaultAspect: CGFloat = 2.0
    
    func parse(item: ChatEntity) -> [ChatFragment] {
        let scanner = Scanner(string: item.text)
        let ratios = item.imageRatios
        var result: [ChatFragment] = []
        var imagesCount = 0
        while !scanner.isAtEnd {
            var text: NSString?
            var img: NSString?
            scanner.scanUpTo("<img src=\"", into: &text)
            scanner.scanString("<img src=\"", into: nil)
            if let text = text {
                    result.append(ChatFragment.text(SaneText(text: text as String)))
            }
            
            scanner.scanUpTo("\">", into: &img)
            scanner.scanString("\">", into: nil)
            if let img = img {
                let aspect: CGFloat
                if imagesCount < ratios.count {
                    aspect = ratios[imagesCount]
                } else {
                    aspect = defaultAspect
                }
                if let idx = Int(img as String), idx < item.images.count {
                    result.append(ChatFragment.image(urlString: item.images[idx],
                                                     urlStringSmall: item.smallImages[idx],
                                                     aspect: aspect))
                    imagesCount += 1
                }
            }
            text = nil
            img = nil
        }
        return result
    }
    
}
