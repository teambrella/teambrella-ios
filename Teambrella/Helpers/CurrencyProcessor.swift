//
//  CurrencyProcessor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct CurrencyProcessor {
    let code: String
    
    var symbol: String? {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
    
}
