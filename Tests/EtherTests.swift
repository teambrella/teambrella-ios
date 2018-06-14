//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import XCTest

@testable import Teambrella

class EtherTests: XCTestCase {

    // MARK: Ether

    func testEtherToGwei() {
        let item = Ether(1.0000000001)
        XCTAssertEqual(Gwei(item).value, 1000000000.1)

    }

    func testEtherToMEth() {
        let item = Ether(1.0000000001)
        XCTAssertEqual(MEth(item).value, 1000.0000001)

    }

    // MARK: Gwei

    func testGweiToEther() {
        let item = Gwei(123)
        XCTAssertEqual(Ether(item).value, 0.000000123)
    }

    // MARK: Wei

    func testWeiFromMEthNotThrows() {
        let meth = MEth(128)
        XCTAssertNoThrow(try Wei.integerConversion(from: meth))
    }

    func testWeiFromMEth() {
        let meth = MEth(128)
        do {
            let wei = try Wei.integerConversion(from: meth)
            XCTAssertEqual(wei.value, 128_000_000_000_000_000)
        } catch {
            XCTAssertTrue(false)
        }
    }
    
}
