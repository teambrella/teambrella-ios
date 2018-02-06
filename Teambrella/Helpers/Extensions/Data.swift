//
//  Data.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.03.17.

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

import Foundation

extension Data {
    var base58String: String {
        return BTCBase58StringWithData(self)
    }
    
    var hexString: String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    init(hex: String) {
        var hex = hex
        // in case there is odd number of bytes (it may happen if we use String(int, radix: 16) )
        // we need to add 0 in front of the string
        if hex.count % 2 != 0 { hex = "0" + hex }

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
