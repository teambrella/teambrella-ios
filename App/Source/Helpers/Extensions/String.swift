//
// Created by Yaroslav Pasternak on 31.03.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension String {
    var base58Data: Data {
        return BTCDataFromBase58(self) as Data
    }
    
    var dateFromTeambrella: Date? {
        return Formatter.teambrella.date(from: self)
    }
    
    func link(substring: String, urlString: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        guard let range = self.range(of: substring) else { return attributedString }
        
        let nsRange = NSRange(range, in: self)
        attributedString.addAttribute(.link, value: urlString, range: nsRange)
        return attributedString
    }
    
    func attributedBoldString(nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let nonBoldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
    
    static func formattedNumber(_ double: Double) -> String {
        guard double < 1000.0 else { return String(format: "%.0f", double) }
        
        let truncatedNumber = round(double * 100) / 100.0
        if fabs(truncatedNumber.truncatingRemainder(dividingBy: 1)) < 0.01 {
            if truncatedNumber == -0.0 {
                return "0"
            }
               return String(format: "%.0f", truncatedNumber)
        } else {
            return String(truncatedNumber)
        }
    }
    
    static func formattedNumber(_ float: Float) -> String {
        return formattedNumber(Double(float))
    }
    
    static func formattedNumber(_ cgFloat: CGFloat) -> String {
        return formattedNumber(Double(cgFloat))
    }
    
    static func truncatedNumber(_ double: Double) -> String {
        return String(Int(double + 0.5))
    }
    
    static func truncatedNumber(_ float: Float) -> String {
        return truncatedNumber(Double(float))
    }
    
    static func truncatedNumber(_ cgFloat: CGFloat) -> String {
        return truncatedNumber(Double(cgFloat))
    }
    
}
