//
//  ModelDataSet.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 26/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

open class ModelDataSet: NSObject, NSCoding {

    open fileprivate (set) var model_name: String?
    open fileprivate (set) var units_wind: String?
    open fileprivate (set) var units_temp: String?
    open fileprivate (set) var units_distance: String?
    open fileprivate (set) var model_data: [ModelData]
    open fileprivate (set) var status: Status?
    open fileprivate (set) var max_wind: Double?
    open fileprivate (set) var max_wind_dir_txt: String?
    open fileprivate (set) var max_wind_time_local: String?
    open fileprivate (set) var model_color: String?
    open fileprivate (set) var spot: Spot?
    
    convenience public init?(dictionary: [String : Any]) {
        self.init(dictionary: dictionary, andSpot: nil)
    }
    
    public init(model_data: [ModelData]) {
        self.model_data = model_data
        super.init()
    }
    
    public convenience init?(dictionary: [String : Any], andSpot spot: Spot?) {
        var model_data = [ModelData]()
        if let modelDataArray: [[String: Any]] = (dictionary["model_data"] as? [[String: Any]]) {
            for dictionary: [String : Any] in modelDataArray {
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
                    if let lon = spot?.lon, let lat = spot?.lat {
                        modelDataDic["lat"] = Int(lat) as Any?
                        modelDataDic["lon"] = Int(lon) as Any?
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
        if let statusDictionary = dictionary["status"] as? [String: Any] {
            self.status = Status(dictionary: statusDictionary)
        }
        max_wind = (dictionary["max_wind"] as? Double)
        max_wind_dir_txt = (dictionary["max_wind_dir_txt"] as? String)
        max_wind_time_local = (dictionary["max_wind_time_local"] as? String)
        model_color = (dictionary["model_color"] as? String)
    }
    
    open override var description: String {
        let description: String = "\(self.model_name) \(self.status) \(self.spot)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(self.units_wind, forKey: "units_wind")
        encoder.encode(self.units_temp, forKey: "units_temp")
        encoder.encode(self.units_distance, forKey: "units_distance")
        encoder.encode(self.model_data, forKey: "model_data")
        encoder.encode(self.status, forKey: "status")
        encoder.encode(self.max_wind, forKey: "max_wind")
        encoder.encode(self.max_wind_dir_txt, forKey: "max_wind_dir_txt")
        encoder.encode(self.max_wind_time_local, forKey: "max_wind_time_local")
        encoder.encode(self.model_color, forKey: "model_color")
        encoder.encode(self.spot, forKey: "spot")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        if let model_data = decoder.decodeObject(forKey: "model_data") as? [ModelData] {
            self.init(model_data: model_data)
        } else {
            return nil
        }
        units_wind = decoder.decodeObject(forKey: "units_wind") as? String
        units_temp = decoder.decodeObject(forKey: "units_temp") as? String
        units_distance = decoder.decodeObject(forKey: "units_distance") as? String
        status = decoder.decodeObject(forKey: "status") as? Status
        max_wind = decoder.decodeObject(forKey: "max_wind") as? Double
        max_wind_dir_txt = decoder.decodeObject(forKey: "max_wind_dir_txt") as? String
        max_wind_time_local = decoder.decodeObject(forKey: "max_wind_time_local") as? String
        model_color = decoder.decodeObject(forKey: "model_color") as? String
        spot = decoder.decodeObject(forKey: "spot") as? Spot
    }
}
