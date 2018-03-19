//
//  Graph.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 10/03/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//

open class Graph {
    open fileprivate (set) var spot_id: Int
    open fileprivate (set) var image_url: String?
    open fileprivate (set) var status: Status?
    open fileprivate (set) var name: String?
    open fileprivate (set) var local_timezone: String?
    open fileprivate (set) var units_wind: String?
    open fileprivate (set) var units_temp: String?
    open fileprivate (set) var max_avg: Double?
    open fileprivate (set) var max_avg_dir_text: String?
    open fileprivate (set) var max_avg_time_local: String?
    open fileprivate (set) var max_fx_avg: Double?
    open fileprivate (set) var max_fx_avg_dir_text: String?
    open fileprivate (set) var max_fx_avg_time_utc: String?
    open fileprivate (set) var last_ob_time_local: String?
    open fileprivate (set) var last_ob_dir_txt: String?
    open fileprivate (set) var last_ob_gust: Double?
    open fileprivate (set) var last_ob_avg: Double?
    open fileprivate (set) var last_ob_lull: Double?
    open fileprivate (set) var last_ob_temp: Double?
    open fileprivate (set) var upgrade_available: Bool?
    open fileprivate (set) var last_ob_dir: Int?
    
    
    public init(spot_id: Int, dictionary: [String : Any]) {
        self.spot_id = spot_id        
        image_url = dictionary["image_url"] as? String
        if let statusDictionary = dictionary["status"] as? [String: Any] {
            self.status = try? Status(dictionary: statusDictionary)
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
        upgrade_available = BoolConverter.convert(dictionary["upgrade_available"])
        last_ob_dir = dictionary["last_ob_dir"] as? Int
    }
}
