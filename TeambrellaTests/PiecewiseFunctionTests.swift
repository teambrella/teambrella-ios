//
//  PiecewiseFunctionTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

class PiecewiseFunctionTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testInitialization() {
        let validPoints = PiecewiseFunction((1, 5), (5, 7), (7, 9))
        XCTAssertNotNil(validPoints)
        
        let invalidPoints = PiecewiseFunction((1, 5), (1, 7), (7, 9))
        XCTAssertNil(invalidPoints)
    }
    
    func testInsertion() {
        let function = PiecewiseFunction((1, 5), (5, 7), (7, 9))
        XCTAssertNotNil(function)
        
        if var f = function {
            XCTAssertTrue(f.addPoint(x: 4, value: 12))
            XCTAssertFalse(f.addPoint(x: 4, value: 12))
        }
    }
    
    func testResult() {
        var function = PiecewiseFunction((5, 5), (1, 1), (7, 9))
        XCTAssertNotNil(function)
        
        XCTAssertEqual(function?.value(at: 6), 7)
        XCTAssertEqual(function?.value(at: 4), 4)
        
        function?.addPoint(x: 3, value: 7)
        XCTAssertEqual(function?.value(at: 4), 6)
    }
    
    func testOutOfBounds() {
        let function = PiecewiseFunction((5, 5), (1, 1), (7, 7))
        XCTAssertNotNil(function)
        
        XCTAssertNil(function?.value(at: 0))
        XCTAssertNil(function?.value(at: 8))
        XCTAssertNotNil(function?.value(at: 2))
    }
    
}
