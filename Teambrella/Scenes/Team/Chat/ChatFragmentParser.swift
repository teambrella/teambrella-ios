//
//  ChatFragmentParser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

enum ChatFragment {
    case text(String)
    case image(urlString: String, aspect: CGFloat)
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
                result.append(ChatFragment.text(text as String))
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
