//
//  ModelDataSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 26/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//


public class ModelDataSet: NSObject, NSCoding {

    public private (set) var model_name: String?
    public private (set) var units_wind: String?
    public private (set) var units_temp: String?
    public private (set) var units_distance: String?
    public private (set) var model_data: [ModelData]
    public private (set) var status: Status?
    public private (set) var max_wind: Double?
    public private (set) var max_wind_dir_txt: String?
    public private (set) var max_wind_time_local: String?
    public private (set) var model_color: String?
    public private (set) var spot: Spot?
    
    convenience public init?(dictionary: [String : AnyObject]) {
        self.init(dictionary: dictionary, andSpot: nil)
    }
    
    public init(model_data: [ModelData]) {
        self.model_data = model_data
        super.init()
    }
    
    public convenience init?(dictionary: [String : AnyObject], andSpot spot: Spot?) {
        var model_data = [ModelData]()
        if let modelDataArray: [[String: AnyObject]] = (dictionary["model_data"] as? [[String: AnyObject]]) {
            for dictionary: [String : AnyObject] in modelDataArray {
                // For some reason we do not get location on all modelData, so lets add it
                var modelDataDic = dictionary
                var updateLocation = false
                if let _ = modelDataDic["lat"] as? String {
                    updateLocation = true
                }
                if let _ = modelDataDic["lon"] as? String {
                    updateLocation = true
                }
                if updateLocation {
                    if let lon = spot?.lon, lat = spot?.lat {
                        modelDataDic["lat"] = Int(lat)
                        modelDataDic["lon"] = Int(lon)
                    }
                    
                }
                let modelData = ModelData(dictionary: modelDataDic)
                model_data.append(modelData)
            }
            self.init(model_data: model_data)
        } else {
            return nil
        }
        self.spot = spot
        model_name = (dictionary["model_name"] as? String)
        units_wind = (dictionary["units_wind"] as? String)
        units_temp = (dictionary["units_temp"] as? String)
        units_distance = (dictionary["units_distance"] as? String)
        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
            self.status = Status(dictionary: statusDictionary)
        }
        max_wind = (dictionary["max_wind"] as? Double)
        max_wind_dir_txt = (dictionary["max_wind_dir_txt"] as? String)
        max_wind_time_local = (dictionary["max_wind_time_local"] as? String)
        model_color = (dictionary["model_color"] as? String)
    }
    
    public override var description: String {
        let description: String = "\(self.model_name) \(self.status) \(self.spot)"
        return "<\(self.dynamicType): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.units_wind, forKey: "units_wind")
        encoder.encodeObject(self.units_temp, forKey: "units_temp")
        encoder.encodeObject(self.units_distance, forKey: "units_distance")
        encoder.encodeObject(self.model_data, forKey: "model_data")
        encoder.encodeObject(self.status, forKey: "status")
        encoder.encodeObject(self.max_wind, forKey: "max_wind")
        encoder.encodeObject(self.max_wind_dir_txt, forKey: "max_wind_dir_txt")
        encoder.encodeObject(self.max_wind_time_local, forKey: "max_wind_time_local")
        encoder.encodeObject(self.model_color, forKey: "model_color")
        encoder.encodeObject(self.spot, forKey: "spot")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        if let model_data = decoder.decodeObjectForKey("model_data") as? [ModelData] {
            self.init(model_data: model_data)
        } else {
            return nil
        }
        units_wind = decoder.decodeObjectForKey("units_wind") as? String
        units_temp = decoder.decodeObjectForKey("units_temp") as? String
        units_distance = decoder.decodeObjectForKey("units_distance") as? String
        status = decoder.decodeObjectForKey("status") as? Status
        max_wind = decoder.decodeObjectForKey("max_wind") as? Double
        max_wind_dir_txt = decoder.decodeObjectForKey("max_wind_dir_txt") as? String
        max_wind_time_local = decoder.decodeObjectForKey("max_wind_time_local") as? String
        model_color = decoder.decodeObjectForKey("model_color") as? String
        spot = decoder.decodeObjectForKey("spot") as? Spot
    }
}