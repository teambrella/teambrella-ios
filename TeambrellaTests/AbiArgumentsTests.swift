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

import XCTest

@testable import Teambrella

class AbiArgumentsTests: XCTestCase {
    
    func testExample() {
        do {
            let string = try AbiArguments.encodeToHex(args: [["7FAEA7BF543F36DAE9D379C67979EF10C824F3FC"], 2020])
            let sample = """
                        0000000000000000000000000000000000000000000000000000000000000040\
                        00000000000000000000000000000000000000000000000000000000000007E4\
                        0000000000000000000000000000000000000000000000000000000000000001\
                        0000000000000000000000007FAEA7BF543F36DAE9D379C67979EF10C824F3FC
                        """
            XCTAssertNotNil(string)
            XCTAssertEqual(string, sample)
        } catch {
            print(error)
            XCTAssertTrue(false)
        }
    }
    
    func testExampleShort() {
        do {
            let string = try AbiArguments.encodeToHex(args: [[String](), 2020])
            let sample = """
                        0000000000000000000000000000000000000000000000000000000000000040\
                        00000000000000000000000000000000000000000000000000000000000007E4\
                        0000000000000000000000000000000000000000000000000000000000000000
                        """
            XCTAssertNotNil(string)
            XCTAssertEqual(string, sample)
        } catch {
            print(error)
            XCTAssertTrue(false)
        }
    }
    
    func testByteArray() {
        let array: [Int8] = [1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4]
        var data = Data()
        for item in array {
            var item = item
            let intData = Data(bytes: &item, count: MemoryLayout.size(ofValue: item))
            data.append(intData)
        }
  
        do {
            let string = try AbiArguments.encodeToHex(args: [data])
            let sample = """
                        0000000000000000000000000000000000000000000000000000000000000020\
                        0000000000000000000000000000000000000000000000000000000000000021\
                        0101010101010101010102020202020202020202030303030303030303030404\
                        0400000000000000000000000000000000000000000000000000000000000000
                        """
            XCTAssertNotNil(string)
            XCTAssertEqual(string, sample)
        } catch {
            print(error)
            XCTAssertTrue(false)
        }
    }

    func testAmountValue() {
        let amount = NSDecimalNumber(string: "0.00067")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000000002615C87FFE000")
    }

    func testAmountValue2() {
        let amount = NSDecimalNumber(string: "0.00482326")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "000000000000000000000000000000000000000000000000001122BABAF59800")
    }

    func testAmountValue3() {
        let amount = NSDecimalNumber(string: "0.00125837")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000000004787b18d89400".uppercased())
    }

    func testAmountIona0() {
        let amount = NSDecimalNumber(string: "0.00000211")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "000000000000000000000000000000000000000000000000000001EB45CCEC00")
    }

    func testAmountIona1() {
        let amount = NSDecimalNumber(string: "0.00017648")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000000000A081F3B5C000")
    }

    func testAmountIona2() {
        let amount = NSDecimalNumber(string: "0.00018195")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000000000A57B891DEC00")
    }

    func testAmountIona3() {
        let amount = NSDecimalNumber(string: "0.00000423")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "000000000000000000000000000000000000000000000000000003D8DFA5BC00")
    }

    func testAmountIona4() {
        let amount = NSDecimalNumber(string: "0.00037682")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "000000000000000000000000000000000000000000000000000156B73E3E8800")
    }

    func testAmountLarge() {
        let amount = NSDecimalNumber(string: "666")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000241A9B4F617A280000".uppercased())
    }

    func testAmountSmall() {
        let amount = NSDecimalNumber(string: "0.000000000000000001")
        let abi = AbiArguments.parseDecimalAmount(decimal: amount)
        XCTAssertEqual(abi, "0000000000000000000000000000000000000000000000000000000000000001".uppercased())
    }


}
