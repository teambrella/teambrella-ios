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
import BigNumber

@testable import Teambrella

class BigNumberTests: XCTestCase {
    
    func testBTCBigNumber() {
        let weis = BTCMutableBigNumber(int64: 666).multiply(BTCBigNumber(int64: 1_000_000_000_000_000_000))
        
        XCTAssertNotNil(weis)
        XCTAssertEqual(weis!.hexString.uppercased(), "241A9B4F617A280000".uppercased())
    }
    
    func testConversion() {
        let value = Decimal(string: "0.00713923")
        XCTAssertNotNil(value)
        let weis = value! * 1_000_000_000_000_000_000
        let weisHex = BInt((weis as NSDecimalNumber).stringValue)?.asString(radix: 16)
        print(weisHex)
        XCTAssertEqual(weisHex?.fromBase64, "0.00713923")
    }
}
