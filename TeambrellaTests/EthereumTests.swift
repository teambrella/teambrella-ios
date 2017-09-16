//
//  EthereumTests.swift
//  TeambrellaTests
//
//  Created by Yaroslav Pasternak on 15.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import XCTest

@testable import Teambrella

class EthereumTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testString() {
        let processor = EthereumProcessor.standard
        let string = processor.ethAddress
        print(string)
        XCTAssertNotNil(string)
    }
    
    func testSignature() {
        let processor = EthereumProcessor.standard
        let signature = processor.publicKeySignature
        print("public signature: \(signature)")
        XCTAssertNotNil(signature)
    }
    
}
