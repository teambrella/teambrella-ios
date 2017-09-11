//
//  SocketDataTests.swift
//  TeambrellaTests
//
//  Created by Yaroslav Pasternak on 11.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
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
