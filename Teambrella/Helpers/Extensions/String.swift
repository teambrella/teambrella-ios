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
}
