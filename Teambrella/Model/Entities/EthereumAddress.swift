//
/* Copyright(C) 2017 Teambrella, Inc.
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
import SwiftKeccak

struct EthereumAddress: Decodable {
    let string: String
    let hasChecksum: Bool

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        guard let address = EthereumAddress(string: value) else {
            throw TeambrellaErrorFactory.malformedEthereumAddress()
        }

        self = address
    }
    
    init?(string: String) {
        var string = string
        if string.lowercased().hasPrefix("ethereum:") {
            let index = string.index(string.startIndex, offsetBy: 9)
            string = String(string[index...])
        }
        if string.lowercased().hasPrefix(" ") {
            let index = string.index(string.startIndex, offsetBy: 1)
            string = String(string[index...])
        }
        if string.lowercased().hasPrefix("\n") {
            let index = string.index(string.startIndex, offsetBy: 1)
            string = String(string[index...])
        }
        if string.hasPrefix("0x") {
            let index = string.index(string.startIndex, offsetBy: 2)
            string = String(string[index...])
        }
        let pattern = "^[a-fA-F0-9]{40}$"
        guard string.range(of: pattern, options: .regularExpression) != nil else { return nil }
        
        if string.lowercased() == string || string.uppercased() == string {
            hasChecksum = false
        } else {
            /*
            let hashBytes = [UInt8](keccak256(string.lowercased()))
            print("string size: \(string.count)")
            print("hash bytes size: \(hashBytes.count)")
            hashBytes.forEach { print("\($0) ", terminator: "") }
            for idx in 0..<40 {
               let index = string.index(string.startIndex, offsetBy: idx)
                let char = String(string[index])
                if (hashBytes[idx] > 7 && char.uppercased() != char)
                    || (hashBytes[idx] <= 7 && char.lowercased() != char) {
                    return nil
                }
            }
 */
            hasChecksum = true
        }
        self.string = "0x" + string
    }
}
