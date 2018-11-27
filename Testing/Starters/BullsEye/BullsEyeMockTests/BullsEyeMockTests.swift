//
//  BullsEyeMockTests.swift
//  BullsEyeMockTests
//
//  Created by Samman Thapa on 11/27/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import XCTest
@testable import BullsEye

class MockUserDefaults: UserDefaults
{
    var gameStyleChanged = 0
    
    override func set(_ value: Int, forKey defaultName: String) {
        if defaultName == "gameStyle"
        {
            gameStyleChanged += 1
        }
    }
}

class BullsEyeMockTests: XCTestCase
{
    var controllerUnderTest: ViewController!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController!
        mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        controllerUnderTest.defaults = mockUserDefaults
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        controllerUnderTest = nil
        mockUserDefaults = nil
    }

    // Mock to test interaction with UserDefaults
    func testGameStyleCanBeChanged()
    {
        // given
        let segmentedControl = UISegmentedControl()
        
        // when
        XCTAssertEqual(mockUserDefaults.gameStyleChanged, 0, "gameStyleChanged should be 0 before sendActions")
        
        segmentedControl.addTarget(controllerUnderTest, action: #selector(ViewController.chooseGameStyle(_:)), for: .valueChanged)
        segmentedControl.sendActions(for: .valueChanged)
        
        // then
        XCTAssertEqual(mockUserDefaults.gameStyleChanged, 1, "gameStyle user defaults wasn't changed")
    }

}
