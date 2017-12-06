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

struct ChatFragmentHeightCalculator {
    let width: CGFloat
    let standardRatio: CGFloat
    let font: UIFont
    
    init(width: CGFloat, font: UIFont, standardRatio: CGFloat = 2.0) {
        self.width = width
        self.font = font
        self.standardRatio = standardRatio
    }
    
    func heights(for fragments: [ChatFragment]) -> [CGFloat] {
        return fragments.flatMap { height(for: $0) }
    }
    
    func height(for fragment: ChatFragment) -> CGFloat {
        switch fragment {
        case let .text(text):
            return height(for: text)
        case let .image(_, _, ratio):
            return height(for: ratio)
        }
    }
    
    func height(for text: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedStringKey.font: font],
                                            context: nil)
        return ceil(boundingBox.height) + 8
    }
    
    func height(for imageRatio: CGFloat) -> CGFloat {
        return width / imageRatio
    }
}
