//
//  SocketDataTests.swift
//  TeambrellaTests
//
//  Created by Yaroslav Pasternak on 11.09.17.
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

class SocketDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testString() {
        let string = "13;12345;abbabbabbbaaaa;edededededededee;Petya"
        let action = SocketAction(string: string)
        XCTAssertNotNil(action)
        
        XCTAssertEqual(action!.command, SocketCommand.theyTyping)
        switch action!.data {
        case let SocketData.theyTyping(teamID: teamID, userID: userID, topicID: topicID, name: name):
            XCTAssertEqual(12345, teamID)
            XCTAssertEqual("abbabbabbbaaaa", userID)
            XCTAssertEqual("edededededededee", topicID)
            XCTAssertEqual("Petya", name)
            XCTAssertEqual(string, action!.data.stringValue)
        default:
            XCTAssertTrue(false)
        }
    }
    
}
