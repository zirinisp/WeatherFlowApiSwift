//
//  ModelData.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

public class ModelData: Codable {
    public let cloudCover: Double?
    public let easting: Double?
    public let isShortPremium: Bool?
    public let isUpgradeAvailable: Bool?
    public var lat: Double?
    public var lon: Double?
    public let maxWindSpeed: Double?
    public let maxWindSpeedDistance: Double?
    public let modelID: Int?
    public let modelRunID: Int?
    public let modelRunName: String?
    public let modelRunTimeUTC: String?
    public let modelTimeLocal: String?
    public let modelTimeUTC: String?
    public let northing: Double?
    public let precipType: String?
    public let precipProb: Double?
    public let pres: Double?
    public let pressureAtHeight: Double?
    public let relativeHumidity: Double?
    public let temp: Double?
    public let totalPrecip: Double?
    public let vis: Double?
    public let waveDirection: Int?
    public let waveHeight: Double?
    public let wavePeriod: Double?
    public let windDir: Int?
    public let windDirTxt: String?
    public let windGust: Double?
    public let windSpeed: Double?
    
    enum CodingKeys: String, CodingKey {
        case cloudCover = "cloud_cover"
        case easting = "easting"
        case isShortPremium = "is_short_premium"
        case isUpgradeAvailable = "is_upgrade_available"
        case lat = "lat"
        case lon = "lon"
        case maxWindSpeed = "max_wind_speed"
        case maxWindSpeedDistance = "max_wind_speed_distance"
        case modelID = "model_id"
        case modelRunID = "model_run_id"
        case modelRunName = "model_run_name"
        case modelRunTimeUTC = "model_run_time_utc"
        case modelTimeLocal = "model_time_local"
        case modelTimeUTC = "model_time_utc"
        case northing = "northing"
        case precipType = "precip_type"
        case precipProb = "prob_precip"
        case pres = "pres"
        case pressureAtHeight = "pressure_at_height"
        case relativeHumidity = "relative_humidity"
        case temp = "temp"
        case totalPrecip = "total_precip"
        case vis = "vis"
        case waveDirection = "wave_direction"
        case waveHeight = "wave_height"
        case wavePeriod = "wave_period"
        case windDir = "wind_dir"
        case windDirTxt = "wind_dir_txt"
        case windGust = "wind_gust"
        case windSpeed = "wind_speed"
    }

    public lazy var modelTime: Date? = {
        if let dateString = self.modelTimeUTC {
            let date: Date? = WeatherFlowApiSwift.dateFormatter.date(from: dateString)
            return date
        }
        return nil
    }()
    
    var description: String {
        let description: String = "%0.1f %0.1f \(self.lat ?? 0.0) %0.1f \(self.lon ?? 0.0)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    
    func updateWith(spot: Spot) {
        self.lat = spot.lat
        self.lon = spot.lon
    }
}
