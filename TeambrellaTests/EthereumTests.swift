//
//  EthereumTests.swift
//  TeambrellaTests
//
//  Created by Yaroslav Pasternak on 15.09.2017.
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
//

import XCTest

@testable import Teambrella

class EthereumTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testString() {
        let processor = EthereumProcessor.standard
        let string = processor.ethAddressString
        XCTAssertNotNil(string)
    }
    
    func testSignature() {
        let processor = EthereumProcessor.standard
        let signature = processor.publicKeySignature
        XCTAssertNotNil(signature)
    }
    
    func testLength() {
        let processor = EthereumProcessor.standard
        let signature = processor.publicKeySignature!
        let length = signature.count - 2 // because of "0x" prefix
        XCTAssertEqual(length, 65 * 2)
    }
    
    func testInitialLetters() {
        let processor = EthereumProcessor.standard
        let signature = processor.publicKeySignature!
         XCTAssertTrue(signature.hasPrefix("0x1b") || signature.hasPrefix("0x1c"))
    }
    
}
