//
//  Data.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension Data {
    var base58String: String {
        return BTCBase58StringWithData(self)
    }
    
    var hexString: String {
        let bytes = [UInt8](self)
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}
