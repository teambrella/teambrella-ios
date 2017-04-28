//
//  UUIDTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import XCTest

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
        let a = UUID(uuidString: "10000000-0018-1000-0001-020304050605")!
        let b = UUID(uuidString: "10000000-0018-1000-0001-020304050605")!
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
    
}
