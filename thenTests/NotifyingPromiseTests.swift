//
//  NotifyingPromiseTests.swift
//  thenTests
//
//  Created by Mads Kleemann on 10/02/2019.
//  Copyright © 2019 s4cha. All rights reserved.
//

import XCTest
@testable import then

class NotifyingPromiseTests: XCTestCase {
    
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    struct NotifyingPromiseTestError: Error {}
    
    func testNotifyingPromiseKeepsBlocksIsSetToTrue() {
        let p = NotifyingPromise<Int>()
        XCTAssertEqual(p.keepBlocks, true)
    }
    
    func testNotifyingPromiseCanSucceedMultipleTimes() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")
        
        let p = NotifyingPromise<Int>()
  
        waitTime(0.1) {
            p.fulfill(1)
        }
        waitTime(0.2) {
            p.fulfill(2)
        }

        var numberOfTimesThenWasCalled = 0
        
        p.then { i in
            numberOfTimesThenWasCalled += 1
            if i == 1 {
                e1.fulfill()
            } else if i == 2 {
                e2.fulfill()
            }
            
        }
        waitForExpectations(timeout: 0.3) { (error) in
            XCTAssertEqual(numberOfTimesThenWasCalled, 2)
        }
    }
    
    func testNotifyingPromiseCanSucceedAndFail() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")
        
        let p = NotifyingPromise<Int>()
        
        waitTime(0.1) {
            p.fulfill(1)
        }

        waitTime(0.2) {
            p.fulfill(2)
        }
        
        var numberOfCallsToThen = 0
        p.then { i in
            numberOfCallsToThen += 1
            if i == 1 {
                e1.fulfill()
            } else if i == 2 {
                e2.fulfill()
            }
        }
        
        waitForExpectations(timeout: 0.4) { (error) in
            XCTAssertEqual(p.keepBlocks, true)
            XCTAssertEqual(numberOfCallsToThen, 2)
        }
    }
    
    func testNotifyingPromiseCanSucceedAndFailAndSucceed() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")
        let e3 = expectation(description: "")
        
        let p = NotifyingPromise<Int>()
        
        waitTime(0.1) {
            p.fulfill(1)
        }
        waitTime(0.2) {
            p.reject(NotifyingPromiseTestError())
        }
        waitTime(0.3) {
            p.fulfill(2)
        }
        
        var numberOfCallsToThen = 0
        var numberOfCallsToOnError = 0
        p.then { i in
            numberOfCallsToThen += 1
            if i == 1 {
                e1.fulfill()
            } else if i == 2 {
                e3.fulfill()
            }
            
        }.onError { (error) in
            numberOfCallsToOnError += 1
            guard error as? NotifyingPromiseTestError != nil else {
                XCTFail("testRecoverCanThrowANewError failed")
                return
            }
            e2.fulfill()
        }
        
        waitForExpectations(timeout: 0.4) { (error) in
            XCTAssertEqual(p.keepBlocks, true)
            XCTAssertEqual(numberOfCallsToThen, 2)
            XCTAssertEqual(numberOfCallsToOnError, 1)
        }
    }
    
    
    func testNotifyingPromiseCanFailAndSucceed() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")
        
        let p = NotifyingPromise<Int>()
        
        waitTime(0.1) {
            p.reject(NotifyingPromiseTestError())
        }
        
        waitTime(0.2) {
            p.fulfill(1)
        }
        var numberOfCallsToThen = 0
        var numberOfCallsToOnError = 0
        p.then { _ in
            numberOfCallsToThen += 1
            e1.fulfill()
        }.onError { (_) in
            numberOfCallsToOnError += 1
            e2.fulfill()
        }
        
        waitForExpectations(timeout: 0.3) { (error) in
            XCTAssertEqual(p.keepBlocks, true)
            XCTAssertEqual(numberOfCallsToThen, 1)
            XCTAssertEqual(numberOfCallsToOnError, 1)
        }
    }
}
