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

class StringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    func testPositiveCent() {
       let value = 0.01
        let string = ValueToTextConverter.textFor(amount: value)
        XCTAssertEqual(string, "0.01")
    }
    
    func testPositiveSmallReminder() {
        let value = 2.001
        let string = ValueToTextConverter.textFor(amount: value)
        XCTAssertEqual(string, "2")
    }
    
    func testNegativeCent() {
        let value = -0.0840516553
        let string = ValueToTextConverter.textFor(amount: value)
        XCTAssertEqual(string, "-0.08")
    }
    
    func testNegativeSmallReminder() {
        let value = -2.0040516553
        let string = ValueToTextConverter.textFor(amount: value)
        XCTAssertEqual(string, "-2")
    }
    
    func testNegativeSmallNumber() {
        let value = -0.003
        let string = ValueToTextConverter.textFor(amount: value)
        XCTAssertEqual(string, "0")
    }
    
}
