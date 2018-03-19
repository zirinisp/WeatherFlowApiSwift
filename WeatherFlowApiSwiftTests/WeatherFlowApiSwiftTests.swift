//
//  WeatherFlowApiSwiftTests.swift
//  WeatherFlowApiSwiftTests
//
//  Created by Pantelis Zirinis on 27/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import XCTest
import CoreLocation
@testable import WeatherFlowApiSwift

class WeatherFlowApiSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        WeatherFlowApiSwift.apiKey = "fc39fe9f-a896-4cef-81dd-50c666855480"
        let session = try! WeatherFlowApiSwift.getToken()!
        XCTAssertNotNil(session.token, "Not token was returned")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(WeatherFlowApiSwift.isReady, "Weather Flow is not ready")
        do {
            let spot = try WeatherFlowApiSwift.getClosestSpotByCoordinate(CLLocationCoordinate2D(latitude: 42.56, longitude: -82.806), distance: 10)
            XCTAssertNotNil(spot)
        } catch  {
            XCTFail(error.localizedDescription)
        }
    }
/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
  */
}
