//
//  ModelData.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

public class ModelData: NSObject, NSCoding {
    public var cloud_cover: Double?
    public var lat: Double?
    public var lon: Double?
    public var max_wind_speed: Double?
    public var max_wind_speed_distance: Double?
    public var model_id: Int?
    public var model_run_id: Int?
    public var model_run_name: String?
    public var model_run_time_utc: String?
    public var model_time_local: String?
    public var model_time_utc: String?
    public var precip_type: String?
    public var pres: Double?
    public var prob_precip: Double?
    public var temp: Double?
    public var total_precip: Double?
    public var vis: Double?
    public var wave_direction: Int?
    public var wave_height: Double?
    public var wave_period: Double?
    public var wind_dir: Int?
    public var wind_dir_txt: String?
    public var wind_speed: Double?
    
    public var modelTime: NSDate? {
        if let dateString = self.model_time_utc {
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            NSDateFormatter.setDefaultFormatterBehavior(NSDateFormatterBehavior.BehaviorDefault)
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
            let date: NSDate? = dateFormatter.dateFromString(dateString)
            return date
        }
        return nil
    }
    
    convenience public init(dictionary: [NSObject : AnyObject]) {
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
    
    public override var description: String {
        let description: String = "%0.1f %0.1f \(self.lat) %0.1f \(self.lon)"
        return "<\(self.dynamicType): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.cloud_cover, forKey: "cloud_cover")
        encoder.encodeObject(self.lat, forKey: "lat")
        encoder.encodeObject(self.lon, forKey: "lon")
        encoder.encodeObject(self.max_wind_speed, forKey: "max_wind_speed")
        encoder.encodeObject(self.max_wind_speed_distance, forKey: "max_wind_speed_distance")
        encoder.encodeObject(self.model_id, forKey: "model_id")
        encoder.encodeObject(self.model_run_id, forKey: "model_run_id")
        encoder.encodeObject(self.model_run_name, forKey: "model_run_name")
        encoder.encodeObject(self.model_run_time_utc, forKey: "model_run_time_utc")
        encoder.encodeObject(self.model_time_local, forKey: "model_time_local")
        encoder.encodeObject(self.model_time_utc, forKey: "model_time_utc")
        encoder.encodeObject(self.modelTime, forKey: "modelTime")
        encoder.encodeObject(self.precip_type, forKey: "precip_type")
        encoder.encodeObject(self.pres, forKey: "pres")
        encoder.encodeObject(self.prob_precip, forKey: "prob_precip")
        encoder.encodeObject(self.temp, forKey: "temp")
        encoder.encodeObject(self.total_precip, forKey: "total_precip")
        encoder.encodeObject(self.vis, forKey: "vis")
        encoder.encodeObject(self.wave_direction, forKey: "wave_direction")
        encoder.encodeObject(self.wave_height, forKey: "wave_height")
        encoder.encodeObject(self.wave_period, forKey: "wave_period")
        encoder.encodeObject(self.wind_dir, forKey: "wind_dir")
        encoder.encodeObject(self.wind_dir_txt, forKey: "wind_dir_txt")
        encoder.encodeObject(self.wind_speed, forKey: "wind_speed")
    }
    
    convenience required public init(coder decoder: NSCoder) {
        self.init()
        cloud_cover = decoder.decodeObjectForKey("cloud_cover") as? Double
        lat = decoder.decodeObjectForKey("lat") as? Double
        lon = decoder.decodeObjectForKey("lon") as? Double
        max_wind_speed = decoder.decodeObjectForKey("max_wind_speed") as? Double
        max_wind_speed_distance = decoder.decodeObjectForKey("max_wind_speed_distance") as? Double
        model_id = decoder.decodeObjectForKey("model_id") as? Int
        model_run_id = decoder.decodeObjectForKey("model_run_id") as? Int
        model_run_name = decoder.decodeObjectForKey("model_run_name") as? String
        model_run_time_utc = decoder.decodeObjectForKey("model_run_time_utc") as? String
        model_time_local = decoder.decodeObjectForKey("model_time_local") as? String
        model_time_utc = decoder.decodeObjectForKey("model_time_utc") as? String
        precip_type = decoder.decodeObjectForKey("precip_type") as? String
        pres = decoder.decodeObjectForKey("pres") as? Double
        prob_precip = decoder.decodeObjectForKey("prob_precip") as? Double
        temp = decoder.decodeObjectForKey("temp") as? Double
        total_precip = decoder.decodeObjectForKey("total_precip") as? Double
        vis = decoder.decodeObjectForKey("vis") as? Double
        wave_direction = decoder.decodeObjectForKey("wave_direction") as? Int
        wave_height = decoder.decodeObjectForKey("wave_height") as? Double
        wave_period = decoder.decodeObjectForKey("wave_period") as? Double
        wind_dir = decoder.decodeObjectForKey("wind_dir") as? Int
        wind_dir_txt = decoder.decodeObjectForKey("wind_dir_txt") as? String
        wind_speed = decoder.decodeObjectForKey("wind_speed") as? Double
    }
}
