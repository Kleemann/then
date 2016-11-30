//
//  OnErrorTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 08/08/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import XCTest
import then

class OnErrorTests: XCTestCase {

    func testError() {
        let errorExpectation = expectation(description: "onError called")
        let finallyExpectation = expectation(description: "Finally called")
        fetchUserId()
            .then(fetchUserNameFromId)
            .then(failingFetchUserFollowStatusFromName)
            .then { isFollowed in
                XCTFail("then block shouldn't be called")
            }.onError { e in
                XCTAssertTrue((e as? MyError) == MyError.defaultError)
                errorExpectation.fulfill()
            }.finally {
                finallyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testOnErrorCalledWhenSynchronousRejects() {
        let errorblock = expectation(description: "error block called")
        promise1()
            .then(syncRejectionPromise())
            .then(syncRejectionPromise())
            .onError { (error) -> Void in
                errorblock.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testThenAfterOnErrorWhenSynchronousResolves() {
        let thenblock = expectation(description: "then block called")
        promise1()
            .then(promise1())
            .onError { _ in
                XCTFail("on Error shouldn't be called")
            }.then { _ in
                 thenblock.fulfill()
            }
        waitForExpectations(timeout: 1, handler: nil)
    }


    func testMultipleErrorBlockCanBeRegisteredOnSamePromise() {
        let error1 = expectation(description: "error called")
        let error2 = expectation(description: "error called")
        let error3 = expectation(description: "error called")
        let error4 = expectation(description: "error called")
        let p = failingFetchUserFollowStatusFromName("")
        p.onError { _ in
            error1.fulfill()
        }
        p.onError { _ in
            error2.fulfill()
        }
        p.onError { _ in
            error3.fulfill()
        }
        p.onError { _ in
            error4.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnFail() {
        let errorExpectation = expectation(description: "then called")
        failingFetchUserFollowStatusFromName("")
            .then { id in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                errorExpectation.fulfill()
            }.onError { e in
                XCTFail("Second on Error shouldn't be called")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTwoConsecutivErrorBlocks2ndShouldNeverBeCalledOnSuccess() {
        let thenExpectation = expectation(description: "then called")
        fetchUserId()
            .then { id in
                thenExpectation.fulfill()
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
            }.onError { e in
                XCTFail("on Error shouldn't be called")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
