//
//  ChatTextParser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftSoup

struct ChatTextParser {
    enum ChatPieceType {
        case text, image
    }
    
    func populate(cell: ChatCell, with item: ChatEntity) {
        let scanner = Scanner(string: item.text)
        while !scanner.isAtEnd {
            var text: NSString?
            var img: NSString?
            scanner.scanUpTo("<img src=\"", into: &text)
            scanner.scanString("<img src=\"", into: nil)
            if let text = text {
                addText(string: text as String, to: cell)
            }
            scanner.scanUpTo("\">", into: &img)
            scanner.scanString("\">", into: nil)
            
            if let img = img {
                addImage(string: img as String, to: cell, with: item)
            }
        }
    }
    
//    func populateHTML(cell: ChatCell, with item: ChatEntity) {
//        let document = Document(
//    }
    
    func addImage(string: String, to cell: ChatCell, with item: ChatEntity) {
        if string.hasPrefix("http") {
            cell.add(image: string)
        } else if let idx = Int(string), idx < item.images.count {
            let fullText = service.server.urlString(string: item.images[idx])
            cell.add(image: fullText)
        }
    }
    
    func addText(string: String, to cell: ChatCell) {
        cell.add(text: string)
    }
}
