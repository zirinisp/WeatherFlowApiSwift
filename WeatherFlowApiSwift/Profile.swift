//
//  Profile.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//


public class Profile {
    public private (set) var profile_id: Int?
    public private (set) var name: String?
    public private (set) var master: Bool?
    public private (set) var alerts_enabled: Bool?
    public private (set) var created_by: String?
    public private (set) var date_created: String?
    public private (set) var lat_center: Double?
    public private (set) var lon_center: Double?
    public private (set) var lat_max: Double?
    public private (set) var lat_min: Double?
    public private (set) var lon_max: Double?
    public private (set) var lon_min: Double?
    public private (set) var views: Int?
    public private (set) var activity: String?
    public private (set) var my_profile: Bool?
    public private (set) var follower_count: Int?
    public private (set) var spot_count: Int?
    public private (set) var current_cond_count: Int?
    public private (set) var model_table_count: Int?
    public private (set) var stats_count: Int?
    public private (set) var archive_count: Int?
    public private (set) var map_count: Int?
    public private (set) var description: String?
    
    convenience public init(dictionary: [String : AnyObject]) {
        self.init()
        profile_id = (dictionary["profile_id"] as? Int)
        name = (dictionary["name"] as? String)
        master = (dictionary["master"] as? Bool)
        alerts_enabled = (dictionary["alerts_enabled"] as? Bool)
        created_by = (dictionary["created_by"] as? String)
        date_created = (dictionary["date_created"] as? String)
        lat_center = (dictionary["lat_center"] as? Double)
        lon_center = (dictionary["lon_center"] as? Double)
        lat_max = (dictionary["lat_max"] as? Double)
        lat_min = (dictionary["lat_min"] as? Double)
        lon_max = (dictionary["lon_max"] as? Double)
        lon_min = (dictionary["lon_min"] as? Double)
        views = (dictionary["views"] as? Int)
        activity = (dictionary["activity"] as? String)
        my_profile = (dictionary["my_profile"] as? Bool)
        follower_count = (dictionary["follower_count"] as? Int)
        spot_count = (dictionary["spot_count"] as? Int)
        current_cond_count = (dictionary["current_cond_count"] as? Int)
        model_table_count = (dictionary["model_table_count"] as? Int)
        stats_count = (dictionary["stats_count"] as? Int)
        archive_count = (dictionary["archive_count"] as? Int)
        map_count = (dictionary["map_count"] as? Int)
        description = (dictionary["description"] as? String)
    }
}
