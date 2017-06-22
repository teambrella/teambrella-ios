//
//  PiecewiseFunctionTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
        let function = PiecewiseFunction((5, 5), (1, 1), (7, 9))
        XCTAssertNotNil(function)
        
        XCTAssertEqual(function?.value(at: 6), 7)
        XCTAssertEqual(function?.value(at: 4), 4)
    }
    
    func testOutOfBounds() {
        let function = PiecewiseFunction((5, 5), (1, 1), (7, 7))
        XCTAssertNotNil(function)
        
        XCTAssertNil(function?.value(at: 0))
        XCTAssertNil(function?.value(at: 8))
        XCTAssertNotNil(function?.value(at: 2))
    }
    
}
