//
//  RunOnTests.swift
//  thenTests
//
//  Created by Mads Kleemann on 06/04/2019.
//  Copyright © 2019 s4cha. All rights reserved.
//

import XCTest
@testable import then

class RunOnTests: XCTestCase {
    
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
 
    func testPromiseRunsOnCustomQueue() {
        let e = expectation(description: "")
        
        let label = "Promise.test.queue.1"
        let queue = DispatchQueue(label: label, qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        let p = Promise<Int>(callback: { (resolve, reject) in
            print("QUEUE: " + Thread.current.threadName)
            if Thread.current.threadName == label {
                e.fulfill()
                 resolve(0)
            } else {
                XCTFail("Promise not resolved on wrong thread")
            }
            
        }).runOn(queue)
            
        
        p.then {
            print($0)
        }

        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
//    func testPromiseSucceedsOnMainQueueWhenRunningFromCustomQueue() {
//        let e = expectation(description: "")
//
//        let p = Promise<Int>()
//
//        let label = "Promise.test.queue"
//        let queue = DispatchQueue(label: label, qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//
//        waitTime(0.1) {
//            queue.async {
//                p.fulfill(1)
//            }
//
//        }
//
//        p.resolveOn(.main)
//            .then { _ in
//                if Thread.current.threadName != label {
//                    e.fulfill()
//                    return
//                }
//                XCTFail("Promise not resolved on main thread")
//        }
//
//        waitForExpectations(timeout: 0.2, handler: nil)
//    }
}
