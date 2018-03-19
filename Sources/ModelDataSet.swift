//
//  ModelDataSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 26/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

public struct ModelDataSet: Codable {
    public let  modelName: String?
    public let  unitsWind: String?
    public let  unitsTemp: String?
    public let  unitsDistance: String?
    public let  modelData: [ModelData]?
    public let  status: Status?
    public let  maxWind: Double?
    public let  maxWindDirTxt: String?
    public let  maxWindTimeLocal: String?
    public let  modelColor: String?
    public let  tzName: String?
    public let  isPremium: Bool?
    public let  isUpgradeAvailable: Bool?
    public let  graphDataExists: Bool?
    public let  spot: Spot?

    
    enum CodingKeys: String, CodingKey {
        case modelName = "model_name"
        case unitsWind = "units_wind"
        case unitsTemp = "units_temp"
        case unitsDistance = "units_distance"
        case modelData = "model_data"
        case status = "status"
        case maxWind = "max_wind"
        case maxWindDirTxt = "max_wind_dir_txt"
        case maxWindTimeLocal = "max_wind_time_local"
        case modelColor = "model_color"
        case tzName = "tz_name"
        case isPremium = "is_premium"
        case isUpgradeAvailable = "is_upgrade_available"
        case graphDataExists = "graphDataExists"
        case spot
    }
    
    public var description: String {
        var description: String = "\(self.modelName ?? "No Model Name") "
        if let status = self.status {
            description += "\(status) "
        } else {
            description += "No Status "
        }
        if let spot = self.spot {
            description += "\(spot)"
        } else {
            description += "No Spot"
        }
        return "<\(type(of: self)): \(self), \(description)>"
    }
}
