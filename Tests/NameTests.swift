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

import Foundation
import XCTest

@testable import Teambrella

class NameTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    func testInit() {
        XCTAssertEqual("Andreas", name().first)
    }
    
    func testShort() {
        XCTAssertEqual("Andreas da Alvaro", name().short)
    }
    
    func testLastName() {
        XCTAssertEqual("de Ribaldo", name().last)
    }
    
    func testApostrophe() {
        XCTAssertEqual("la d'Avignac", name().components[2].entire)
    }
    
    func testStrangeFirstName() {
        let name = Name(fullName: "da d'Abruzzi Pistoia")
        XCTAssertEqual("da d'Abruzzi", name.first)
        XCTAssertEqual("Pistoia", name.last)
    }
    
    private func name() -> Teambrella.Name {
        return Name(fullName: "Andreas da Alvaro la d'Avignac Martinez de Ribaldo")
    }
}
