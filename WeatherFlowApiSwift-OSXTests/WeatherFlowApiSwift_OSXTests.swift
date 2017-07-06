//
//  WeatherFlowApiSwift_OSXTests.swift
//  WeatherFlowApiSwift-OSXTests
//
//  Created by Pantelis Zirinis on 07/10/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//

import XCTest
import WeatherFlowApiSwift
import CoreLocation

class WeatherFlowApiSwift_OSXTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        WeatherFlowApiSwift.apiKey = ""
        try? WeatherFlowApiSwift.getToken()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(WeatherFlowApiSwift.isReady, "Weather Flow is not ready")
        let spot = try? WeatherFlowApiSwift.getClosestSpotByCoordinate(CLLocationCoordinate2D(latitude: 42.56, longitude: -82.806), distance: 10)
        XCTAssertNotNil(spot)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
