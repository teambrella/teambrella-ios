//
//  ChatFragmentHeightCalculator.swift
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

struct ChatFragmentSizeCalculator {
    let width: CGFloat
    let standardRatio: CGFloat
    let font: UIFont
    
    init(width: CGFloat, font: UIFont, standardRatio: CGFloat = 2.0) {
        self.width = width
        self.font = font
        self.standardRatio = standardRatio
    }
    
    func sizes(for fragments: [ChatFragment]) -> [CGSize] {
        return fragments.compactMap { size(for: $0) }
    }
    
    func size(for fragment: ChatFragment) -> CGSize {
        switch fragment {
        case let .text(text):
            return size(for: text)
        case let .image(_, _, ratio):
            return size(for: ratio)
        }
    }
    
    func size(for text: String) -> CGSize {
        return TextSizeCalculator().size(for: text, font: font, maxWidth: width)
    }
    
    func size(for imageRatio: CGFloat) -> CGSize {
        return CGSize(width: width, height: width / imageRatio)
    }
}

struct TextSizeCalculator {
    func size(for text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedStringKey.font: font],
                                            context: nil)
        return boundingBox.size
    }
}
