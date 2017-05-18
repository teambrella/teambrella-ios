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
    
    init(hex: String) {
        let scalars = hex.unicodeScalars
        var bytes: [UInt8] = [UInt8](repeating: 0, count: (scalars.count + 1) >> 1)
        for (index, scalar) in scalars.enumerated() {
            var nibble = scalar.hexNibble
            if index & 1 == 0 {
                nibble <<= 4
            }
            bytes[index >> 1] |= nibble
        }
        self = Data(bytes: bytes)
    }
}

extension UnicodeScalar {
    var hexNibble: UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        } else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        } else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) not a legal hex nibble")
    }
}
