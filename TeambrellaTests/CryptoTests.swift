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

class CryptoTests: XCTestCase {
    let privateKey: String = "cUNX4HYHK3thsjDKEcB26qRYriw8uJLtt8UvDrM98GbUBn22HMrY"
    
    override func setUp() {
        super.setUp()
    }
    
    func testKey() {
        let key = Key(base58String: privateKey, timestamp: 0)
        XCTAssertEqual(key.privateKey, privateKey)
    }

    /*
    func testBTCKey() {
        let key = BTCKey(wif: privateKey)
        
        XCTAssertEqual(key?.wif, privateKey)
    }
    
    func testBTCKey2() {
        let key = BTCKey(wif: privateKey)
        
        XCTAssertEqual(key?.privateKey.base58CheckString(), privateKey)
    }
*/
    
    func testWIF() {
        let key = BTCKey()!
        key.isPublicKeyCompressed = true
        print(key.wif)
        key.isPublicKeyCompressed = false
        print(key.wif)
        XCTAssertTrue(true)
    }
    
}
