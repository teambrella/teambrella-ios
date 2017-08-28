//
//  ChatFragmentHeightCalculator.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
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
        case let .image(_, ratio):
            return height(for: ratio)
        }
    }
    
    func height(for text: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSFontAttributeName: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
    
    func height(for imageRatio: CGFloat) -> CGFloat {
        return width / imageRatio
    }
}
