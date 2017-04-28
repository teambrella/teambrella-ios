//
// Created by Yaroslav Pasternak on 31.03.17.
// Copyright (c) 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension String {
    var base58Data: Data {
        return BTCDataFromBase58(self) as Data
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
}
