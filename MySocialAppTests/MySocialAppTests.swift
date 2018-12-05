//
//  MySocialAppTests.swift
//  MySocialAppTests
//
//  Created by Developers Mycoachfootball on 05/12/2018.
//  Copyright © 2018 4Tech. All rights reserved.
//

import XCTest
@testable import MySocialApp

class MySocialAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct MSA {
        static let msaAppId = "u777154255154a653612"
        static let msa = MySocialApp.Builder().setAppId(msaAppId).build()
    }

    func testMSACreate() {
        let index = "24"
        let userName = "\(index)aNewUserName"
        let email = "\(index)aNewEmail@mycoachsport.com"
        let password = "aNewPassword"
        let firstName = "aNewFirstName"

        let userSession = try? MSA.msa.blockingCreateAccount(username: userName, email: email, password: password, firstName: firstName)
        XCTAssert(userSession != nil)
    }

}
