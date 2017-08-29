//
//  FetchTests.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.05.17.

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
