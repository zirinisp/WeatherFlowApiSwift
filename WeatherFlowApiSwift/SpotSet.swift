//
//  SpotSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

public class SpotSet {
    
    public var spots = [Spot]()
    public var status: Status?
    public var search_lat: Double?
    public var search_lon: Double?
    public var search_dist: Int?
    public var spot_count: Int?
    public var num_per_page: Int?
    public var page: Int?
    public var units_temp: String?
    public var units_wind: String?
    public var profile_name: String?
    public var profile_id: Int?
    public var units_distance: String?
    public var profile_alerts_enabled: Bool?
    public var accuracy: Int?
    public var current_time_utc: String?
    public var current_time_local: String?
    public var center_lat: Double?
    public var center_lon: Double?
    public var profile: Profile?
    
    convenience public init(dictionary: [String : AnyObject]) {
        self.init()

        let data_names: [String]? = (dictionary["data_names"] as? [String])
        let data_values: [[AnyObject]]? = (dictionary["data_values"] as? [[AnyObject]])
        self.setSpotsWithNames(data_names, values: data_values)

        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
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
        if let profileDictionary = dictionary["profile"] as? [String: AnyObject] {
            profile = Profile(dictionary: profileDictionary)
        }
    }
    
    func description() -> String {
        let description: String = "%0.4f %0.4f\n\(self.search_lat)"
        return "<\(self.dynamicType): \(self), \(description)>"
    }
    
    func setSpotsWithNames(data_names: [String]?, values data_values: [[AnyObject]]?) {
        var array: [Spot] = [Spot]()
        if let names = data_names, values = data_values {
            for values: [AnyObject] in values {
                var dictionary: [String : AnyObject] = [String : AnyObject]()
                var index: Int = 0
                for key: String in names {
                    let value: AnyObject = values[index]
                    dictionary[key] = value
                    index++
                }
                if let spot: Spot = Spot(dictionary: dictionary) {
                    array.append(spot)                    
                }
            }
        }
        self.spots = array
    }
}

