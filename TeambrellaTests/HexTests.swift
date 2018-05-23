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

class HexTests: XCTestCase {
    
    func testData() {
        let str = Hex().formattedString(data: Data(hex: "7FAEA7BF543F36DAE9D379C67979EF10C824F3FC"), bytesCount: 32)
        XCTAssertNotNil(str)
    }
    
    func testOtherString() {
        let str = Hex().formattedString(string: "123", bytesCount: 32)
        XCTAssertNotNil(str)
    }

    func testTransaction() {
        let hex = Hex()
        let a0 = "5452"
        let a1 = String(format: "%064x", "2020")
        let a2 = String(format: "%064x", 5)
        let a3 = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
        let a4raw = [0.00000211, 0.00017648, 0.00000211, 0.00000211, 0.00018195, 0.00000423, 0.00000211, 0.00000211, 0.00037682]
        let a4 = a4raw.compactMap { Int($0 * 1_000_000_000_000_000_000) }.map { String($0) }

        do {
            let data = try hex.data(from: a0, a1, a2, a3, a4)
            XCTAssertNotNil(data)
        } catch {
            print("Error: \(error)")
            XCTAssertTrue(false)
        }
    }

    func testFormat1() {
        let hex = Hex()
        let data = hex.formattedString(string: "123", bytesCount: 32)
        XCTAssertEqual(data, "0000000000000000000000000000000000000000000000000000000000000123")
    }
    
}
