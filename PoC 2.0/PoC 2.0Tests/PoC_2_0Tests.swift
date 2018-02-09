//
//  PoC_2_0Tests.swift
//  PoC 2.0Tests
//
//  Created by Cris Toozs on 04/06/2017.
//  Copyright © 2017 Cris Toozs. All rights reserved.
//

import XCTest
@testable import PoC_2_0

class PoC_2_0Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // tl;dr set initial variables here
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // tl;dr undo anything that needs to be done after tests
        super.tearDown()
    }
    
    func testExample() {
        let layout = UICollectionViewFlowLayout()

        let home = HomeController(collectionViewLayout: layout)
        
        home.viewDidLoad()
        XCTAssert(home.collectionView?.backgroundColor == UIColor.white)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here (such as a sorting algorithm).
        }
    }
    
}
