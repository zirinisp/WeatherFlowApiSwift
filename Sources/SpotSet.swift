//
//  SpotSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

open class SpotSet {
    
    open var spots = [Spot]()
    open var status: Status?
    open var search_lat: Double?
    open var search_lon: Double?
    open var search_dist: Int?
    open var spot_count: Int?
    open var num_per_page: Int?
    open var page: Int?
    open var units_temp: String?
    open var units_wind: String?
    open var profile_name: String?
    open var profile_id: Int?
    open var units_distance: String?
    open var profile_alerts_enabled: Bool?
    open var accuracy: Int?
    open var current_time_utc: String?
    open var current_time_local: String?
    open var center_lat: Double?
    open var center_lon: Double?
    open var profile: Profile?
    
    convenience public init(dictionary: [String : Any]) {
        self.init()

        let data_names: [String]? = (dictionary["data_names"] as? [String])
        let data_values: [[Any]]? = (dictionary["data_values"] as? [[Any]])
        self.setSpotsWithNames(data_names, values: data_values)

        if let statusDictionary = dictionary["status"] as? [String: Any] {
            self.status = Status(dictionary: statusDictionary)
        }
        search_lat = (dictionary["search_lat"] as? Double)
        search_lon = (dictionary["search_lon"] as? Double)
        search_dist = (dictionary["search_dist"] as? Int)
        spot_count = (dictionary["spot_count"] as? Int)
        num_per_page = (dictionary["num_per_page"] as? Int)
        page = (dictionary["page"] as? Int)
        units_temp = (dictionary["units_temp"] as? String)
        units_wind = (dictionary["units_wind"] as? String)
        profile_name = (dictionary["profile_name"] as? String)
        profile_id = (dictionary["profile_id"] as? Int)
        units_distance = (dictionary["units_distance"] as? String)
        profile_alerts_enabled = (dictionary["profile_alerts_enabled"] as? Bool)
        accuracy = (dictionary["accuracy"] as? Int)
        current_time_utc = (dictionary["current_time_utc"] as? String)
        current_time_local = (dictionary["current_time_local"] as? String)
        center_lat = (dictionary["center_lat"] as? Double)
        center_lon = (dictionary["center_lon"] as? Double)
        if let profileDictionary = dictionary["profile"] as? [String: Any] {
            profile = Profile(dictionary: profileDictionary)
        }
    }
    
    func description() -> String {
        let description: String = "%0.4f %0.4f\n\(self.search_lat)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    
    func setSpotsWithNames(_ data_names: [String]?, values data_values: [[Any]]?) {
        var array: [Spot] = [Spot]()
        if let names = data_names, let values = data_values {
            for values: [Any] in values {
                var dictionary: [String : Any] = [String : Any]()
                var index: Int = 0
                for key: String in names {
                    let value: Any = values[index]
                    dictionary[key] = value
                    index += 1
                }
                if let spot: Spot = Spot(dictionary: dictionary) {
                    array.append(spot)                    
                }
            }
        }
        self.spots = array
    }
}

