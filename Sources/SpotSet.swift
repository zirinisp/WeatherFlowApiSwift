//
//  SpotSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation


public class SpotSet: Codable {
    public let status: Status?
    public let searchLat: Double?
    public let searchLon: Double?
    public let searchDist: Int?
    public let accuracy: Int?
    public let spotCount: Int?
    public let numPerPage: Int?
    public let page: Int?
    public let unitsTemp: String?
    public let unitsWind: String?
    public let unitsDistance: String?
    public let currentTimeUTC: String?
    public let currentTimeLocal: String?
    let dataNames: [String]?
    let dataValues: [[DataValue]]?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case searchLat = "search_lat"
        case searchLon = "search_lon"
        case searchDist = "search_dist"
        case accuracy = "accuracy"
        case spotCount = "spot_count"
        case numPerPage = "num_per_page"
        case page = "page"
        case unitsTemp = "units_temp"
        case unitsWind = "units_wind"
        case unitsDistance = "units_distance"
        case currentTimeUTC = "current_time_utc"
        case currentTimeLocal = "current_time_local"
        case dataNames = "data_names"
        case dataValues = "data_values"
    }
    
    public lazy var spots: [Spot] = {
        var array: [Spot] = [Spot]()
        if let names = self.dataNames, let values = self.dataValues {
            for values: [DataValue] in values {
                var dictionary: [String : DataValue] = [String : DataValue]()
                var index: Int = 0
                for key: String in names {
                    let value = values[index]
                    dictionary[key] = value
                    index += 1
                }
                do {
                    if let jsonString = try dictionary.jsonString() {
                        var spot: Spot = try Spot(jsonString)
                        spot.status = self.status
                        array.append(spot)
                    } else {
                        print("Could not convert to json")
                    }
                } catch {
                    print(error)
                }
            }
        }
        return array
    }()
    
    public func description() -> String {
        let description: String = "%0.4f %0.4f\n\(self.searchLat ?? 0.0)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    
}

enum DataValue: Codable {
    case intArray([Int])
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Int].self) {
            self = .intArray(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }

        if container.decodeNil() {
            self = .null
            return
        }
        print("\(DataValue.self) not found for \(decoder.codingPath)")
        throw DecodingError.typeMismatch(DataValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for DataValue"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intArray(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        case .int(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}
