//
//  FetchTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import XCTest
@testable import Teambrella

/*
 FBName = 10212220476497327;
 Id = 2274;
 Name = "Iaroslav Pasternak";
 PublicKey = 041ad183efed6edd9a126327aeff87b857952ecae31aa93c7423e6118e8bd4453babe68970a423bbbe3485c8aa17c0ee74126379b3f5d02736573f836cc691f2eb;
 TeamId = 2006;
 */

class FetchTests: XCTestCase {
    var teambrella: TeambrellaService!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        teambrella = TeambrellaService()
    }
    
    func testMe() {
         let team = teambrella.fetcher.firstTeam
        XCTAssertNotNil(team)
        
        let me = team!.me(user: teambrella.fetcher.user)
        XCTAssertNotNil(me)
        
        XCTAssertEqual(me!.id, 2274)
    }

}
