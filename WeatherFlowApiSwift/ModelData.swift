//
//  ModelData.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

open class ModelData: NSObject, NSCoding {
    open var cloud_cover: Double?
    open var lat: Double?
    open var lon: Double?
    open var max_wind_speed: Double?
    open var max_wind_speed_distance: Double?
    open var model_id: Int?
    open var model_run_id: Int?
    open var model_run_name: String?
    open var model_run_time_utc: String?
    open var model_time_local: String?
    open var model_time_utc: String?
    open var precip_type: String?
    open var pres: Double?
    open var prob_precip: Double?
    open var temp: Double?
    open var total_precip: Double?
    open var vis: Double?
    open var wave_direction: Int?
    open var wave_height: Double?
    open var wave_period: Double?
    open var wind_dir: Int?
    open var wind_dir_txt: String?
    open var wind_speed: Double?
    
    open var modelTime: Date? {
        if let dateString = self.model_time_utc {
            let dateFormatter: DateFormatter = DateFormatter()
            DateFormatter.defaultFormatterBehavior = DateFormatter.Behavior.default
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            let date: Date? = dateFormatter.date(from: dateString)
            return date
        }
        return nil
    }
    
    convenience public init(dictionary: [AnyHashable: Any]) {
        self.init()
        cloud_cover = (dictionary["cloud_cover"] as? Double)
        lat = (dictionary["lat"] as? Double)
        lon = (dictionary["lon"] as? Double)
        max_wind_speed = (dictionary["max_wind_speed"] as? Double)
        max_wind_speed_distance = (dictionary["max_wind_speed_distance"] as? Double)
        model_id = (dictionary["model_id"] as? Int)
        model_run_id = (dictionary["model_run_id"] as? Int)
        model_run_name = (dictionary["model_run_name"] as? String)
        model_run_time_utc = (dictionary["model_run_time_utc"] as? String)
        model_time_local = (dictionary["model_time_local"] as? String)
        model_time_utc = (dictionary["model_time_utc"] as? String)
        precip_type = (dictionary["precip_type"] as? String)
        pres = (dictionary["pres"] as? Double)
        prob_precip = (dictionary["prob_precip"] as? Double)
        temp = (dictionary["temp"] as? Double)
        total_precip = (dictionary["total_precip"] as? Double)
        vis = (dictionary["vis"] as? Double)
        wave_direction = (dictionary["wave_direction"] as? Int)
        wave_height = (dictionary["wave_height"] as? Double)
        wave_period = (dictionary["wave_period"] as? Double)
        wind_dir = (dictionary["wind_dir"] as? Int)
        wind_dir_txt = (dictionary["wind_dir_txt"] as? String)
        wind_speed = (dictionary["wind_speed"] as? Double)
    }
    
    open override var description: String {
        let description: String = "%0.1f %0.1f \(self.lat) %0.1f \(self.lon)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(self.cloud_cover, forKey: "cloud_cover")
        encoder.encode(self.lat, forKey: "lat")
        encoder.encode(self.lon, forKey: "lon")
        encoder.encode(self.max_wind_speed, forKey: "max_wind_speed")
        encoder.encode(self.max_wind_speed_distance, forKey: "max_wind_speed_distance")
        encoder.encode(self.model_id, forKey: "model_id")
        encoder.encode(self.model_run_id, forKey: "model_run_id")
        encoder.encode(self.model_run_name, forKey: "model_run_name")
        encoder.encode(self.model_run_time_utc, forKey: "model_run_time_utc")
        encoder.encode(self.model_time_local, forKey: "model_time_local")
        encoder.encode(self.model_time_utc, forKey: "model_time_utc")
        encoder.encode(self.modelTime, forKey: "modelTime")
        encoder.encode(self.precip_type, forKey: "precip_type")
        encoder.encode(self.pres, forKey: "pres")
        encoder.encode(self.prob_precip, forKey: "prob_precip")
        encoder.encode(self.temp, forKey: "temp")
        encoder.encode(self.total_precip, forKey: "total_precip")
        encoder.encode(self.vis, forKey: "vis")
        encoder.encode(self.wave_direction, forKey: "wave_direction")
        encoder.encode(self.wave_height, forKey: "wave_height")
        encoder.encode(self.wave_period, forKey: "wave_period")
        encoder.encode(self.wind_dir, forKey: "wind_dir")
        encoder.encode(self.wind_dir_txt, forKey: "wind_dir_txt")
        encoder.encode(self.wind_speed, forKey: "wind_speed")
    }
    
    convenience required public init(coder decoder: NSCoder) {
        self.init()
        cloud_cover = decoder.decodeObject(forKey: "cloud_cover") as? Double
        lat = decoder.decodeObject(forKey: "lat") as? Double
        lon = decoder.decodeObject(forKey: "lon") as? Double
        max_wind_speed = decoder.decodeObject(forKey: "max_wind_speed") as? Double
        max_wind_speed_distance = decoder.decodeObject(forKey: "max_wind_speed_distance") as? Double
        model_id = decoder.decodeObject(forKey: "model_id") as? Int
        model_run_id = decoder.decodeObject(forKey: "model_run_id") as? Int
        model_run_name = decoder.decodeObject(forKey: "model_run_name") as? String
        model_run_time_utc = decoder.decodeObject(forKey: "model_run_time_utc") as? String
        model_time_local = decoder.decodeObject(forKey: "model_time_local") as? String
        model_time_utc = decoder.decodeObject(forKey: "model_time_utc") as? String
        precip_type = decoder.decodeObject(forKey: "precip_type") as? String
        pres = decoder.decodeObject(forKey: "pres") as? Double
        prob_precip = decoder.decodeObject(forKey: "prob_precip") as? Double
        temp = decoder.decodeObject(forKey: "temp") as? Double
        total_precip = decoder.decodeObject(forKey: "total_precip") as? Double
        vis = decoder.decodeObject(forKey: "vis") as? Double
        wave_direction = decoder.decodeObject(forKey: "wave_direction") as? Int
        wave_height = decoder.decodeObject(forKey: "wave_height") as? Double
        wave_period = decoder.decodeObject(forKey: "wave_period") as? Double
        wind_dir = decoder.decodeObject(forKey: "wind_dir") as? Int
        wind_dir_txt = decoder.decodeObject(forKey: "wind_dir_txt") as? String
        wind_speed = decoder.decodeObject(forKey: "wind_speed") as? Double
    }
}
