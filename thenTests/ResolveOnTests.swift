//
//  ResolveOnTests.swift
//  thenTests
//
//  Created by Mads Kleemann on 26/02/2019.
//  Copyright © 2019 s4cha. All rights reserved.
//

import XCTest
@testable import then

class ResolveOnTests: XCTestCase {

    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    struct ResolveOnPromiseTestError: Error {}
    
    func testPromiseSucceedsOnMainQueue() {
        let e = expectation(description: "")
        
        let p = Promise<Int>()
    
        waitTime(0.1) {
            DispatchQueue.global(qos: .background).async {
                p.fulfill(1)
            }
            
        }
        
        p.resolveOn(.main)
            .then { _ in
                dump(Thread.current.threadName)
                if Thread.isMainThread {
                    e.fulfill()
                    return
                }
                XCTFail("Promise not resolved on main thread")
            }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testPromiseFailsOnMainQueue() {
        let e = expectation(description: "")
        
        let p = Promise<Int>()
        
        waitTime(0.1) {
            DispatchQueue.global(qos: .background).async {
                p.reject(ResolveOnPromiseTestError())
            }
            
        }
        
        p.resolveOn(.main)
            .onError { _ in
                if Thread.isMainThread {
                    e.fulfill()
                    return
                }
                XCTFail("Promise not resolved on main thread")
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testPromiseSucceedsOnCustomQueue() {
        let e = expectation(description: "")
        
        let p = Promise<Int>()
        
        waitTime(0.1) {
            DispatchQueue.main.async {
                p.fulfill(1)
            }
            
        }
        let label = "Promise.test.queue"
        let queue = DispatchQueue(label: label, qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        p.resolveOn(queue)
            .then { _ in
                print(Thread.current.threadName)
                if Thread.current.threadName == label {
                    e.fulfill()
                    return
                }
               XCTFail("Promise not resolved on main thread")
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testPromiseSucceedsOnMainQueueWhenRunningFromCustomQueue() {
        let e = expectation(description: "")
        
        let p = Promise<Int>()
        
        let label = "Promise.test.queue"
        let queue = DispatchQueue(label: label, qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        waitTime(0.1) {
            queue.async {
                p.fulfill(1)
            }
            
        }
        
        p.resolveOn(.main)
            .then { _ in
                if Thread.current.threadName != label {
                    e.fulfill()
                    return
                }
                XCTFail("Promise not resolved on main thread")
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
