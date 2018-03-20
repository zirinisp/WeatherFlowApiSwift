//
//  Spot.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

#if os(Linux)
    import CoreLinuxLocation
#else
    import CoreLocation
#endif

public class Spot: Codable {
    
    public let spotId: Int
    public let name: String?
    public let type: Int?
    public let distance: Double?
    public let lat: Double?
    public let lon: Double?
    public let provider: Int?
    public let regionId: Int?
    public let favorite: String?
    public let windAlertExists: String?
    public let windAlertActive: String?
    public let upgradeAvailable: String?
    public let timestamp: String?
    public let avg: Double?
    public let lull: Double?
    public let gust: Double?
    public let dir: Int?
    public let dirText: String?
    public let atemp: Double?
    public let wtemp: Double?
    public var status: Status?
    public let spotMessage: String?
    public let sourceMessage: String?
    public let rank: Double?
    public let favSortOrder: Int?
    public let waveHeight: Double?
    public let wavePeriod: Double?
    public let currentTimeLocal: String?
    public let pres: Double?
    public let timezone: String?
    public let favoriteLists: String?
    public let favSpotId: Int?
    public let windDesc: String?

    enum CodingKeys: String, CodingKey {
        case spotId = "spot_id"
        case name
        case type
        case distance
        case lat
        case lon
        case provider
        case regionId = "region_id"
        case favorite = "is_favorite"
        case windAlertExists = "wind_alert_exists"
        case windAlertActive = "wind_alert_active"
        case upgradeAvailable = "upgrade_available"
        case timestamp
        case avg
        case lull
        case gust
        case dir
        case dirText = "dir_text"
        case atemp
        case wtemp
        case status
        case spotMessage = "spot_message"
        case sourceMessage = "source_message"
        case rank
        case favSortOrder = "fav_sort_order"
        case waveHeight = "wave_height"
        case wavePeriod = "wave_period"
        case currentTimeLocal = "current_time_local"
        case pres
        case timezone
        case favoriteLists = "favorite_lists"
        case favSpotId = "fav_spot_id"
        case windDesc = "wind_desc"
    }
    
    var description: String {
        let description: String = "\(self.spotId) \(self.name ?? "No Name") %0.4f %0.4f"
        return "<\(Swift.type(of: self)): \(self), \(description)>"
    }
    
    public lazy var coordinate: CLLocationCoordinate2D = {
        if let lat = self.lat, let lon = self.lon {
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            if CLLocationCoordinate2DIsValid(coordinate) {
                return coordinate
            }
        }
        #if os(Linux)
            // TODO: We have to fix this some day and make it return nil
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        #else
            return kCLLocationCoordinate2DInvalid
        #endif
    }()
    
    public var title: String? {
        return self.name
    }
    
    public var subtitle: String? {
        return self.windDesc
    }
    
    public func isEqual(_ object: Any?) -> Bool {
        if !(object is Spot) {
            return false
        }
        let spot: Spot = object as! Spot
        return spot.spotId == self.spotId
    }
    
    public mutating func distanceFrom(_ location: CLLocation) -> CLLocationDistance? {
        if CLLocationCoordinate2DIsValid(self.coordinate) {
            let loc: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let dist: CLLocationDistance = loc.distance(from: location)
            return dist
        }
        return nil
    }
    
    public func getModelData() -> ModelDataSet? {
        do {
            return try WeatherFlowApiSwift.getModelDataBySpot(self)
        } catch {
            return nil
        }
    }
    
    public func getModelDataError() throws -> ModelDataSet? {
        return try WeatherFlowApiSwift.getModelDataBySpot(self)
    }

    // THe following dictionary is used for storage on extensions like MKAnnotation
    lazy var _extensionStorage = [String: Any]()
}
