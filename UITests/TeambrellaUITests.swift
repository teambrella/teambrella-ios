//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import XCTest

class TeambrellaUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        let app = XCUIApplication()
        setupSnapshot(app)
        self.app = app
        app.launch()

        continueAfterFailure = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }

    func testScreenshots() {
        // tap "Try Demo"
        app.buttons["tryDemo"].tap()

        // tap "Home"
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 0).tap()
        sleep(1)

        snapshot("0Home")

        // tap "Team"
        tabBarsQuery.buttons.element(boundBy: 1).tap()

        let collectionViewsQuery3 = app.collectionViews
        let collectionViewsQuery = collectionViewsQuery3

        // tap Claims
        collectionViewsQuery.staticTexts.element(boundBy: 2).tap()

        let collectionViewsQuery2 = app.scrollViews.otherElements.collectionViews
        collectionViewsQuery2.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()

        sleep(1)
        collectionViewsQuery.sliders.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.66)

        snapshot("1Claim")

        // tap Chat
        collectionViewsQuery.cells["imageGalleryCell"].children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
        app.collectionViews["UniversalChatCollectionView"].swipeUp()
        snapshot("2Chat")
    }
    
}
