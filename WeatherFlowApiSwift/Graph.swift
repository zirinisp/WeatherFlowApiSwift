//
//  Graph.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 10/03/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//

public class Graph {
    public private (set) var spot_id: Int
    public private (set) var image_url: String?
    public private (set) var status: Status?
    public private (set) var name: String?
    public private (set) var local_timezone: String?
    public private (set) var units_wind: String?
    public private (set) var units_temp: String?
    public private (set) var max_avg: Double?
    public private (set) var max_avg_dir_text: String?
    public private (set) var max_avg_time_local: String?
    public private (set) var max_fx_avg: Double?
    public private (set) var max_fx_avg_dir_text: String?
    public private (set) var max_fx_avg_time_utc: String?
    public private (set) var last_ob_time_local: String?
    public private (set) var last_ob_dir_txt: String?
    public private (set) var last_ob_gust: Double?
    public private (set) var last_ob_avg: Double?
    public private (set) var last_ob_lull: Double?
    public private (set) var last_ob_temp: Double?
    public private (set) var upgrade_available: Bool?
    public private (set) var last_ob_dir: Int?
    
    
    public init(spot_id: Int, dictionary: [String : AnyObject]) {
        self.spot_id = spot_id        
        image_url = dictionary["image_url"] as? String
        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
            self.status = Status(dictionary: statusDictionary)
        }
        name = dictionary["name"] as? String
        local_timezone = dictionary["local_timezone"] as? String
        units_wind = (dictionary["units_wind"] as? String)
        units_temp = (dictionary["units_temp"] as? String)
        max_avg = dictionary["max_avg"] as? Double
        max_avg_dir_text = dictionary["max_avg_dir_text"] as? String
        max_avg_time_local = dictionary["max_avg_time_local"] as? String
        max_fx_avg = dictionary["max_fx_avg"] as? Double
        max_fx_avg_dir_text = dictionary["max_fx_avg_dir_text"] as? String
        max_fx_avg_time_utc = dictionary["max_fx_avg_time_utc"] as? String
        last_ob_time_local = dictionary["last_ob_time_local"] as? String
        last_ob_dir_txt = dictionary["last_ob_dir_txt"] as? String
        last_ob_gust = dictionary["last_ob_gust"] as? Double
        last_ob_avg = dictionary["last_ob_avg"] as? Double
        last_ob_lull = dictionary["last_ob_lull"] as? Double
        last_ob_temp = dictionary["last_ob_temp"] as? Double
        upgrade_available = dictionary["upgrade_available"] as? Bool
        last_ob_dir = dictionary["last_ob_dir"] as? Int
    }
}
