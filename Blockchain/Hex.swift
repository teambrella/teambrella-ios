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

struct Hex {
    enum HexError: Error {
        case stringUnconvertibleToData
        case unsupportedArgument(Any)
    }
    
    func arrayOfHexStrings(from data: Data, bytesCount: Int) -> [String] {
        var result: [String] = []
        var string = ""
        for (idx, byte) in data.enumerated() {
            if idx % bytesCount == 0 && idx > 0 {
                result.append(string)
                string = ""
            }
            string += hexStringFrom(byte: byte)
        }
        if string != "" { result.append(string) }
        return result
    }
    
    func hexStringFrom(byte: UInt8) -> String {
        return String(format: "%02X", byte)
    }
    
    func hexStringFrom(data: Data) -> String {
        return data.map { self.hexStringFrom(byte: $0) }.reduce("", +)
    }
    
    func data(from: Any...) throws -> Data {
        var result = Data()
        for item in from {
            switch item {
            case let item as String:
                let data = createData(from: item)
                result.append(data)
            case let item as [String]:
                for string in item {
                    let data = createData(from: string)
                    result.append(data)
                }
            case let item as Int:
                let data = createData(from: String(item))
                result.append(data)
            case let item as Data:
                result.append(item)
            default:
                throw HexError.unsupportedArgument(item)
            }
        }
        return result
    }
    
    private func createData(from string: String)  -> Data {
        return Data(hex: string)
    }
    
    // 777 to "00000000000000000777"
    func formattedString(integer: Int, bytesCount: Int) -> String {
        let format = "%0\(bytesCount * 2)X"
        return String(format: format, integer)
    }
    
    // "0xABCDEF" to "00000000000000000ABCDEF"
    func formattedString(string: String, bytesCount: Int) -> String? {
        let truncated = truncatePrefix(string: string)
        let data =  createData(from: truncated)
        
        return formattedString(data: data, bytesCount: bytesCount)
    }
    
    func formattedString(data: Data, bytesCount: Int) -> String? {
        guard data.count <= bytesCount else { return nil }
        
        let bytes = [UInt8](data)
        var hexString = ""
        for i in 0..<bytesCount {
            if bytesCount - i <= bytes.count {
                let idx = bytes.count - bytesCount + i
                let byte = bytes[idx]
                hexString += hexStringFrom(byte: byte)
            } else {
                hexString += "00"
            }
        }
        return hexString
    }
    
    func truncatePrefix(string: String) -> String {
        return string.lowercased().hasPrefix("0x")
            ? String(string[string.index(string.startIndex, offsetBy: 2)...])
            : string
    }
    
}
