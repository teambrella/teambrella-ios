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
    case text(String)
    case image(urlString: String, aspect: CGFloat)
}

struct ChatFragmentParser {
    var defaultAspect: CGFloat = 2.0
    let textAdapter = TextAdapter()
    
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
                let parsedText = textAdapter.parsedHTML(string: text as String)
                if parsedText != "" {
                result.append(ChatFragment.text(parsedText))
                }
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
                    result.append(ChatFragment.image(urlString: item.images[idx], aspect: aspect))
                    imagesCount += 1
                }
            }
            text = nil
            img = nil
        }
        return result
    }
    
}
