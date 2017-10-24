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
            let string = try AbiArguments.encodeToHex(Data(hex: "7FAEA7BF543F36DAE9D379C67979EF10C824F3FC"), 2020)
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
            let string = try AbiArguments.encodeToHex([String](), 2020)
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
    
    func testExampleCustom() {
        do {
            let string = try AbiArguments.encodeToHex(["a", "as", "sasasasa"], 2020, "test")
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
}
