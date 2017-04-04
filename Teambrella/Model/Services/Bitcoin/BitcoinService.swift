//
//  BitcoinService.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct BitcoinService {
    static func signature(timestamp: Int64, privateKey: String) -> String {
        guard let privateKey = privateKey.data(using: .utf8) else {
            fatalError("can't convert to data")
        }
        guard let key = BTCKey(privateKey: privateKey) else {
        fatalError("Couldn't create key")
        }
        
        let message = String(timestamp)
        guard let data = key.signature(forMessage: message) else {
        fatalError("Can't create signature data")
        }
    
        return String(data: data, encoding: .utf8) ?? ""
    }
    
}
