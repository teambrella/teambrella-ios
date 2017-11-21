//
//  ChatTextParser.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 20.06.17.

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
            let fullText = URLBuilder().urlString(string: item.images[idx])
            cell.add(image: fullText)
        }
    }
    
    func addText(string: String, to cell: ChatCell) {
        cell.add(text: string)
    }
}
