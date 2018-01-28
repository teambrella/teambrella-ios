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

class AbiArguments {
    struct Constant {
        static let bytesInWord = 32
        static let weisInEth: Decimal = 1_000_000_000_000_000_000
    }
    
    enum AbiArgumentsError: Error {
        case unEncodableArgument(Any)
    }
    
    private var arguments: [Any?] = []
    private var argumentsQueue: [String] = []
    private var extraQueue: [String] = []
    private var extraOffset = 0
    private var currentOffset: Int { return arguments.count * Constant.bytesInWord + extraOffset }
    
    var hexString: String {
        argumentsQueue.removeAll()
        extraQueue.removeAll()
        extraOffset = 0
        for argument in arguments {
            guard let argument = argument else {
                queue(int: 0)
                continue
            }
            
            switch argument {
            case let argument as Int:
                queue(int: argument)
            case let argument as String:
                queue(string: argument)
            case let argument as [Int]:
                queue(array: argument)
            case let argument as [String]:
                queue(array: argument)
            case let argument as Data:
                queue(data: argument)
            default:
                break
            }
        }
        return dequeueAll()
    }
    
    static func encodeToHex(args: [Any]) throws -> String {
        let abiArguments = AbiArguments()
        for argument in args {
            try abiArguments.add(argument)
        }
        
        return abiArguments.hexString
    }

    static func parseDecimalAmount(decimalAmount: String) -> String? {
        /*
            BigDecimal e = new BigDecimal(decimalAmount, MathContext.UNLIMITED);
            BigInteger wei = e.multiply(WEIS_IN_ETH).toBigInteger();
            return Hex.format(wei, BYTES_IN_WORD);
        */
        guard let e: Decimal = Decimal(string: decimalAmount) else {
            print("String \(decimalAmount) is not convertible to Decimal")
            return nil
        }

        let weis: Decimal = e * Constant.weisInEth

        //let e: BInt = BInt(decimalAmount)
        //let weis: BInt = e * BInt(Constant.weisInEth.description)
        return  Hex().formattedString(string: String(describing: weis), bytesCount: Constant.bytesInWord)
    }
    
    func add(_ argument: Any) throws {
        guard isValid(argument) else { throw AbiArgumentsError.unEncodableArgument(argument) }
        
        arguments.append(argument)
    }
    
    func isValid(_ argument: Any) -> Bool {
        let isValid: Bool
        switch argument {
        case _ as Int,
             _ as String,
             _ as Data,
             _ as [String],
             _ as [Int]:
            isValid = true
        default:
            isValid = false
        }
        return isValid
    }
    
    private func queue(int: Int) {
        argumentsQueue.append(Hex().formattedString(integer: int, bytesCount: Constant.bytesInWord))
    }
    
    private func queue(string: String) {
        let hexUtility = Hex()
        let truncated = hexUtility.truncatePrefix(string: string)
        if truncated.count / 2 > Constant.bytesInWord {
            try? queue(data: hexUtility.data(from: truncated))
        } else {
            if let formattedString = hexUtility.formattedString(string: truncated, bytesCount: Constant.bytesInWord) {
                try? queue(data: hexUtility.data(from: formattedString))
               // queue(string: formattedString)
            } else {
                log("AbiArguments can not enqueue string \(string)", type: [.error, .crypto])
            }
        }
    }
    
    private func queue(array: [String]) {
        // 0000000040
        queue(int: currentOffset)
        
        // 0000000002
        // 0000000AAA
        // 0000000BBB
        queueToExtraPart(int: array.count)
        array.forEach { self.queueToExtraPart(string: $0) }
    }
    
    private func queue(array: [Int]) {
        // 0000000040
        queue(int: currentOffset)
        
        // 0000000002
        // 0000000111
        // 0000000222
        queueToExtraPart(int: array.count)
        array.forEach { self.queueToExtraPart(int: $0) }
    }
    
    private func queue(data: Data) {
        // 0000000040
        queue(int: currentOffset)
        
        // 0000000013
        // 1234567890
        // 1230000000
        queueToExtraPart(int: data.count)
        queueToExtraPart(data: data)
    }
    
    private func queueToExtraPart(int: Int) {
        extraQueue.append(Hex().formattedString(integer: int, bytesCount: Constant.bytesInWord))
        extraOffset += Constant.bytesInWord
    }
    
    private func queueToExtraPart(string: String) {
        extraQueue.append(Hex().formattedString(string: string, bytesCount: Constant.bytesInWord) ?? "");
        extraOffset += Constant.bytesInWord
    }
    
    private func queueToExtraPart(data: Data) {
        // [1234567890123] to
        // 1234567890
        // 1230000000
        let n = data.count
        extraQueue.append(Hex().hexStringFrom(data: data))
        extraOffset += n
        
        let rest = n % Constant.bytesInWord
        if rest > 0 {
            let suffixLength = Constant.bytesInWord - rest
            extraQueue.append(Hex().formattedString(string: "", bytesCount: suffixLength) ?? "")
            extraOffset += suffixLength
        }
    }
    
    private func dequeueAll() -> String {
        return argumentsQueue.joined() + extraQueue.joined()
    }
    
}
