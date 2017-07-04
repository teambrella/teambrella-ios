//
// Created by Yaroslav Pasternak on 31.03.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension String {
    var base58Data: Data {
        return BTCDataFromBase58(self) as Data
    }
    
    var base64data: Data? {
        return Data(base64Encoded: self)
    }
    
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    var toBase64: String {
        return Data(self.utf8).base64EncodedString()
    }
    
    var localized: String {
        guard let range = self.range(of: ".") else { return self }
        
        return NSLocalizedString(self,
                                 tableName: self.substring(to: range.lowerBound),
                                 comment: self)
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        let template = localized
        return String(format: template, arguments: arguments)
    }
    
    func split(by count: Int) -> [String] {
        return stride(from: 0, to: characters.count, by: count).map { i -> String in
            let startIndex = self.index(self.startIndex, offsetBy: i)
            let endIndex   = self.index(startIndex, offsetBy: count, limitedBy: self.endIndex) ?? self.endIndex
            return self[startIndex..<endIndex]
        }
    }
    
    var cSharpDate: Date? { return dateFromISO8601 }
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    
    func attributedBoldString(nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]
        let nonBoldAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
        let attrStr = NSMutableAttributedString(string: self, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
}
