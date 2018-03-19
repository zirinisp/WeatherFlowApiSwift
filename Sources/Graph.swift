//
//  Graph.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 10/03/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//

public struct Graph: Codable {
    public let imageUrl: String?
    public let status: Status?
    public let name: String?
    public let localTimezone: String?
    public let unitsWind: String?
    public let unitsTemp: String?
    public let maxAvg: Int?
    public let maxGust: Int?
    public let maxFxWind: Int?
    public let maxFxWindDirTxt: String?
    public let maxFxWindTimeUTC: String?
    public let lastObTimeLocal: String?
    public let lastObDirTxt: String?
    public let lastObTemp: Double?
    public let upgradeAvailable: Bool?
    public let lastObDir: Int?
    public let isDataRestricted: Bool?
    public var spotId: Int?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case status = "status"
        case name = "name"
        case localTimezone = "local_timezone"
        case unitsWind = "units_wind"
        case unitsTemp = "units_temp"
        case maxAvg = "max_avg"
        case maxGust = "max_gust"
        case maxFxWind = "max_fx_wind"
        case maxFxWindDirTxt = "max_fx_wind_dir_txt"
        case maxFxWindTimeUTC = "max_fx_wind_time_utc"
        case lastObTimeLocal = "last_ob_time_local"
        case lastObDirTxt = "last_ob_dir_txt"
        case lastObTemp = "last_ob_temp"
        case upgradeAvailable = "upgrade_available"
        case lastObDir = "last_ob_dir"
        case isDataRestricted = "is_data_restricted"
        case spotId = "spot_id"
    }
}

