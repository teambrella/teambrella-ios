//
//  TeambrellaTests.swift
//  TeambrellaTests
//
//  Created by Yaroslav Pasternak on 28.03.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import XCTest
@testable import Teambrella

class TeambrellaTests: XCTestCase {
    var key: Key!
    
    override func setUp() {
        super.setUp()
        let privateKey = ServerService.Constant.fakePrivateKey
        let key = Key(base58String: privateKey, timestamp: 636269125689610106)
        self.key = key!
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddress() {
        XCTAssertEqual(key.address, ServerService.Constant.fakePrivateKey)
    }
    
    func testPublicKey() {
        XCTAssertEqual(key.publicKey, "0203ca066905e668d1232a33bf5cce76ee1754b0a24ae9c28d20e13b069274742c")
    }
    
    func testSignature() {
        let signature = key.signature
        XCTAssertEqual(signature, "H1nEOvey+WLcE2ImM+6lqUwpOqYxnjFcnqAMqM7YsOZ4JVMri8FK2T+PoyuBZ+cXLsshvHUlDZhWhMRgjFoEHUQ=")//"H1TpwvZo2nOgXg0XAk/HB30r3mBwnLqz9zGPHel87x1SKhMP6QmzEhDiuSe3uEhF6VXfLnJeliyUP3CtZrrEF5Y=")
    }
    
}
