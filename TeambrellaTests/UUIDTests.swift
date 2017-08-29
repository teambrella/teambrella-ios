//
//  UUIDTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.04.17.

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

import XCTest
@testable import Teambrella

class UUIDTests: XCTestCase {
    
    func testLarger() {
        let a = UUID(uuidString: "10000000-0018-1000-0001-020304050607")!
        let b = UUID(uuidString: "10000000-0018-1000-0001-020304050604")!
        XCTAssertTrue(a > b)
        
    }
    
    func testLesser() {
        let a = UUID(uuidString: "10000000-0018-1000-0001-020304050603")!
        let b = UUID(uuidString: "20000000-0018-1000-0001-020304050601")!
        XCTAssertTrue(a < b)
    }
    
    func testEqual() {
        let a = UUID(uuidString: "10000000-0018-1000-2301-020304050605")!
        let b = UUID(uuidString: "10000000-0018-1000-2301-020304050605")!
        XCTAssertTrue(a == b)
    }
    
    func testNotEqual() {
        let a = UUID(uuidString: "10000000-0018-1000-0001-020304050605")!
        let b = UUID(uuidString: "10000000-0018-1000-0001-020304050607")!
        XCTAssertFalse(a == b)
    }
    
    func testSort() {
        let a = UUID(uuidString: "10000004-0018-1000-0001-020304050607")!
        let b = UUID(uuidString: "10000002-0018-1000-0001-020304050604")!
        let c = UUID(uuidString: "10000005-0018-1000-0001-020304050609")!
        let d = UUID(uuidString: "10000003-0018-1000-0001-020304050606")!
        let e = UUID(uuidString: "10000001-0018-1000-0001-020304050601")!
        let array = [a, b, c, d, e].sorted()
        XCTAssertEqual([e, b, d, a, c], array)
    }
    
    func testPresorted() {
        let array: [UUID] = [
            UUID(uuidString: "00000000-0000-0000-0000-000000000000"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000000"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000000"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000001"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000002"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000003"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000a"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000b"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000c"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000d"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000e"),
            UUID(uuidString: "00000000-0000-0000-0000-00000000000f"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000100"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000200"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000300"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000a00"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000b00"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000c00"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000d00"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000e00"),
            UUID(uuidString: "00000000-0000-0000-0000-000000000f00"),
            UUID(uuidString: "00000001-0000-0000-0000-000000000000"),
            UUID(uuidString: "00000002-0000-0000-0000-000000000000"),
            UUID(uuidString: "00000003-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000a-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000b-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000c-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000d-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000e-0000-0000-0000-000000000000"),
            UUID(uuidString: "0000000f-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffff0-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffff1-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffff2-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffff3-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffffa-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffffb-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffffc-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffffd-0000-0000-0000-000000000000"),
            UUID(uuidString: "fffffffe-0000-0000-0000-000000000000"),
            UUID(uuidString: "ffffffff-0000-0000-0000-000000000000")
            ].flatMap { $0 }
        XCTAssertFalse(array.isEmpty)
        XCTAssertEqual(array, array.sorted())
    }
    
}
