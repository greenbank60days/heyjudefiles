//
//  HeyJudeSDKTests.swift
//  HeyJudeSDKTests
//
//  Created by Wayne Eldridge on 2019/02/04.
//  Copyright © 2019 TCT Digital. All rights reserved.
//

import XCTest
@testable import HeyJudeSDK

class HeyJudeSDKTests: XCTestCase {
    
    static let apiKey = "1234567890"
    static let apiProgram = "heyjude"
    
    
    let heyJudeManager = HeyJudeManager(environment: .STAGING, program: apiKey, apiKey: apiProgram)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: - Authentification
    func testAuthentification(){
        
        //TODO: We should get some correct test credentails
        let condition = expectation(description: "Sign In Completion")
        let username = "byrontudhope@gmail.com"
        let password = "zzzzz"
        
        heyJudeManager.SignIn(username: username, password: password, pushToken: nil) { (success, user, error) in
            if success {
                XCTAssert(true)
                condition.fulfill()
            }else {
                XCTAssert(false, error?.apiErrors?.description ?? "") //FIXME: Just check about the error description vs protocol
                condition.fulfill()
                
            }
        }
        
        waitForExpectations(timeout: 30.0, handler: nil)
    }
    
}
