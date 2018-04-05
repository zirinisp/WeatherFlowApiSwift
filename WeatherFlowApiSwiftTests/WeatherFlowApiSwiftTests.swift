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
    
    let bigBayCoordinates = CLLocationCoordinate2D(latitude: -33.80, longitude: 18.46)
    let londonCoordinates = CLLocationCoordinate2D(latitude: 51.51, longitude: -0.13)
    
    lazy var spotSet: SpotSet = {
        do {
            var spotSet = try WeatherFlowApiSwift.getSpotSetByCoordinate(bigBayCoordinates, distance: 40)
            print("Found \(spotSet.spots.count) Spots")
            return spotSet
        } catch {
            XCTFail("\(error)")
            fatalError(error.localizedDescription)
        }
    }()
    
    lazy var londonSpotSet: SpotSet = {
        do {
            var spotSet = try WeatherFlowApiSwift.getSpotSetByCoordinate(londonCoordinates, distance: 50)
            print("Found \(spotSet.spots.count) London Spots")
            return spotSet
        } catch {
            XCTFail("\(error)")
            fatalError(error.localizedDescription)
        }
    }()

    func testSpotSet() {
        var averageLiveWindFound = false

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(WeatherFlowApiSwift.isReady, "Weather Flow is not ready")
        XCTAssertNotNil(self.spotSet.status)
        XCTAssertNotNil(self.spotSet.searchLat)
        XCTAssertNotNil(self.spotSet.searchLon)
        //XCTAssertNotNil(spotSet.searchDist)
        XCTAssertNotNil(self.spotSet.currentTimeUTC)
        XCTAssertNotNil(self.spotSet.unitsWind)
        XCTAssertNotNil(self.spotSet.unitsTemp)
        XCTAssertNotNil(self.spotSet.unitsDistance)
        XCTAssert(self.spotSet.spots.count > 0, "No Spots Found")
        for spot in self.spotSet.spots {
            print(spot.name!)
            XCTAssertNotNil(spot)
            XCTAssertNotNil(spot.lat, spot.name ?? "\(spot.spotId)")
            XCTAssertNotNil(spot.lon, spot.name ?? "\(spot.spotId)")
            if let _ = spot.avg {
                averageLiveWindFound = true
            }
            //XCTAssertNotNil(spot.gust)
            XCTAssertNotNil(spot.atemp, spot.name ?? "\(spot.spotId)")
        }
        XCTAssertTrue(averageLiveWindFound, "Average Wind Not Found Not Found")
    }
    
    func testWeatherForecast() {
        XCTAssert(self.spotSet.spots.count > 0, "No Spots Found")
        var waveHeightFound = false
        var wavePeriodFound = false
        var waveDirectionFound = false
        var precipTypeFound = false
        var totalPrecipFound = false
        //var precipProbFound = false
        var cloudCoverFound = false

        var spots = self.spotSet.spots
        spots.append(contentsOf: self.londonSpotSet.spots)
        
        for spot in spots {
            do {
                guard spot.spotId != 0 else {
                    XCTFail("SpotId not Set")
                    continue
                }
                guard let modelDataSet = try WeatherFlowApiSwift.getModelDataBySpot(spot) else {
                    XCTFail("No Model Data Set Found")
                    continue
                }
                guard let modelDataArray = modelDataSet.modelDataArray else {
                    XCTFail("No Model Data Array Found")
                    continue
                }
                XCTAssert(modelDataArray.count > 0, "Empty model data array")
                for modelData in modelDataArray {
                    XCTAssertNotNil(modelData.lat)
                    XCTAssertNotNil(modelData.lon)
                    XCTAssertNotNil(modelData.temp)
                    XCTAssertNotNil(modelData.maxWindSpeed)
                    XCTAssertNotNil(modelData.modelTimeUTC)
                    XCTAssertNotNil(modelData.pres)
                    XCTAssertNotNil(modelData.windDir)
                    XCTAssertNotNil(modelData.windSpeed)
                    XCTAssertNotNil(modelData.windGust)
                    if let _ = modelData.wavePeriod {
                        wavePeriodFound = true
                    }
                    if let _ = modelData.waveHeight {
                        waveHeightFound = true
                    }
                    if let _ = modelData.waveDirection {
                        waveDirectionFound = true
                    }
                    if let _ = modelData.cloudCover {
                        cloudCoverFound = true
                    }
                    if let _ = modelData.precipType {
                        precipTypeFound = true
                    }
                    if let _ = modelData.totalPrecip {
                        totalPrecipFound = true
                    }
                    // For some reason we are not getting this one back anymore
                    //if let _ = modelData.precipProb {
                    //    precipProbFound = true
                    //}
                }

            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(wavePeriodFound, "Wave Period Not Found")
        XCTAssertTrue(waveHeightFound, "Wave Height Not Found")
        XCTAssertTrue(waveDirectionFound, "Wave Direction Not Found")
        XCTAssertTrue(precipTypeFound, "Precip Type Not Found")
        XCTAssertTrue(totalPrecipFound, "Total Precip Not Found")
        XCTAssertTrue(cloudCoverFound, "Cloud Cover Not Found")
        //XCTAssertTrue(precipProbFound, "Precip Probability Not Found")
    }
    
    func testWeatherForecastAsync() {
        XCTAssert(self.spotSet.spots.count > 0, "No Spots Found")
        var waveHeightFound = false
        var wavePeriodFound = false
        var waveDirectionFound = false
        var precipTypeFound = false
        var totalPrecipFound = false
        //var precipProbFound = false
        var cloudCoverFound = false
        
        var spots = self.spotSet.spots
        spots.append(contentsOf: self.londonSpotSet.spots)
        
        for spot in spots {
            do {
                guard spot.spotId != 0 else {
                    XCTFail("SpotId not Set")
                    continue
                }
                let tokenExpectation = expectation(description: "Weather Request for \(spot.name ?? "No Name")")
                WeatherFlowApiSwift.getModelDataBySpot(spot, completion: { (result) in
                    switch result {
                    case .success(let modelDataSet):
                        guard let modelDataArray = modelDataSet?.modelDataArray else {
                            XCTFail("No Model Data Array Found")
                            tokenExpectation.fulfill()
                            return
                        }
                        XCTAssert(modelDataArray.count > 0, "Empty model data array")
                        for modelData in modelDataArray {
                            XCTAssertNotNil(modelData.lat)
                            XCTAssertNotNil(modelData.lon)
                            XCTAssertNotNil(modelData.temp)
                            XCTAssertNotNil(modelData.maxWindSpeed)
                            XCTAssertNotNil(modelData.modelTimeUTC)
                            XCTAssertNotNil(modelData.pres)
                            XCTAssertNotNil(modelData.windDir)
                            XCTAssertNotNil(modelData.windSpeed)
                            XCTAssertNotNil(modelData.windGust)
                            if let _ = modelData.wavePeriod {
                                wavePeriodFound = true
                            }
                            if let _ = modelData.waveHeight {
                                waveHeightFound = true
                            }
                            if let _ = modelData.waveDirection {
                                waveDirectionFound = true
                            }
                            if let _ = modelData.cloudCover {
                                cloudCoverFound = true
                            }
                            if let _ = modelData.precipType {
                                precipTypeFound = true
                            }
                            if let _ = modelData.totalPrecip {
                                totalPrecipFound = true
                            }
                            // For some reason we are not getting this one back anymore
                            //if let _ = modelData.precipProb {
                            //    precipProbFound = true
                            //}
                        }
                    case .error(let error):
                        XCTFail("\(error)")
                    }
                    tokenExpectation.fulfill()
                })
                waitForExpectations(timeout: 10, handler: nil)
            }
        }
        XCTAssertTrue(wavePeriodFound, "Wave Period Not Found")
        XCTAssertTrue(waveHeightFound, "Wave Height Not Found")
        XCTAssertTrue(waveDirectionFound, "Wave Direction Not Found")
        XCTAssertTrue(precipTypeFound, "Precip Type Not Found")
        XCTAssertTrue(totalPrecipFound, "Total Precip Not Found")
        XCTAssertTrue(cloudCoverFound, "Cloud Cover Not Found")
        //XCTAssertTrue(precipProbFound, "Precip Probability Not Found")
    }
}
