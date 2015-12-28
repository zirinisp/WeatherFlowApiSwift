//
//  Spot.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation
import MapKit
import PazHelperSwift

public class Spot: NSObject, MKAnnotation {
    
    public private (set) var spot_id: Int
    public private (set) var name: String?
    public private (set) var type: Int?
    public private (set) var distance: Double?
    public private (set) var lat: Double?
    public private (set) var lon: Double?
    public private (set) var provider: Int?
    public private (set) var region_id: Int?
    public private (set) var is_favorite: Bool?
    public private (set) var wind_alert_exists: Bool?
    public private (set) var wind_alert_active: Bool?
    public private (set) var upgrade_available: Bool?
    public private (set) var timestamp: String?
    public private (set) var avg: Double?
    public private (set) var lull: Double?
    public private (set) var gust: Double?
    public private (set) var dir: Int?
    public private (set) var dir_text: String?
    public private (set) var atemp: Double?
    public private (set) var wtemp: Double?
    public private (set) var status: Status?
    public private (set) var spot_message: String?
    public private (set) var source_message: String?
    public private (set) var rank: Double?
    public private (set) var fav_sort_order: Int?
    public private (set) var wave_height: Double?
    public private (set) var wave_period: Double?
    public private (set) var current_time_local: String?
    public private (set) var pres: Double?
    public private (set) var timezone: String?
    public private (set) var favorite_lists: String?
    public private (set) var fav_spot_id: Int?
    public private (set) var wind_desc: String?

    public init(spot_id : Int) {
        self.spot_id = spot_id
        super.init()
    }
    
    public convenience init?(dictionary: [String : AnyObject]) {
        if let spot_id = dictionary["spot_id"] as? Int {
            self.init(spot_id: spot_id)
        } else {
            return nil
        }
        self.name = (dictionary["name"] as? String)
        self.type = (dictionary["type"] as? Int)
        self.distance = (dictionary["distance"] as? Double)
        self.lat = (dictionary["lat"] as? Double)
        self.lon = (dictionary["lon"] as? Double)
        self.provider = (dictionary["provider"] as? Int)
        self.region_id = (dictionary["region_id"] as? Int)
        self.is_favorite = (dictionary["is_favorite"] as? Bool)
        self.wind_alert_exists = (dictionary["wind_alert_exists"] as? Bool)
        self.wind_alert_active = (dictionary["wind_alert_active"] as? Bool)
        self.upgrade_available = (dictionary["upgrade_available"] as? Bool)
        self.timestamp = (dictionary["timestamp"] as? String)
        self.avg = (dictionary["avg"] as? Double)
        self.lull = (dictionary["lull"] as? Double)
        self.gust = (dictionary["gust"] as? Double)
        self.dir = (dictionary["dir"] as? Int)
        self.dir_text = (dictionary["dir_text"] as? String)
        self.atemp = (dictionary["atemp"] as? Double)
        self.wtemp = (dictionary["wtemp"] as? Double)
        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
            self.status = Status(dictionary: statusDictionary)
        }
        self.spot_message = (dictionary["spot_message"] as? String)
        self.source_message = (dictionary["source_message"] as? String)
        self.rank = (dictionary["rank"] as? Double)
        self.fav_sort_order = (dictionary["fav_sort_order"] as? Int)
        self.wave_height = (dictionary["wave_height"] as? Double)
        self.wave_period = (dictionary["wave_period"] as? Double)
        self.current_time_local = (dictionary["current_time_local"] as? String)
        self.pres = (dictionary["pres"] as? Double)
        self.timezone = (dictionary["timezone"] as? String)
        self.favorite_lists = (dictionary["favorite_lists"] as? String)
        self.fav_spot_id = (dictionary["fav_spot_id"] as? Int)
        self.wind_desc = (dictionary["wind_desc"] as? String)
        //self.annotationView__ = nil
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.spot_id, forKey: "spot_id")
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.type, forKey: "type")
        encoder.encodeObject(self.distance, forKey: "distance")
        encoder.encodeObject(self.lat, forKey: "lat")
        encoder.encodeObject(self.lon, forKey: "lon")
        encoder.encodeObject(self.provider, forKey: "provider")
        encoder.encodeObject(self.region_id, forKey: "region_id")
        encoder.encodeObject(self.is_favorite, forKey: "is_favorite")
        encoder.encodeObject(self.wind_alert_exists, forKey: "wind_alert_exists")
        encoder.encodeObject(self.wind_alert_active, forKey: "wind_alert_active")
        encoder.encodeObject(self.upgrade_available, forKey: "upgrade_available")
        encoder.encodeObject(self.timestamp, forKey: "timestamp")
        encoder.encodeObject(self.avg, forKey: "avg")
        encoder.encodeObject(self.lull, forKey: "lull")
        encoder.encodeObject(self.gust, forKey: "gust")
        encoder.encodeObject(self.dir, forKey: "dir")
        encoder.encodeObject(self.dir_text, forKey: "dir_text")
        encoder.encodeObject(self.atemp, forKey: "atemp")
        encoder.encodeObject(self.wtemp, forKey: "wtemp")
        encoder.encodeObject(self.status, forKey: "status")
        encoder.encodeObject(self.spot_message, forKey: "spot_message")
        encoder.encodeObject(self.source_message, forKey: "source_message")
        encoder.encodeObject(self.rank, forKey: "rank")
        encoder.encodeObject(self.fav_sort_order, forKey: "fav_sort_order")
        encoder.encodeObject(self.wave_height, forKey: "wave_height")
        encoder.encodeObject(self.wave_period, forKey: "wave_period")
        encoder.encodeObject(self.current_time_local, forKey: "current_time_local")
        encoder.encodeObject(self.pres, forKey: "pres")
        encoder.encodeObject(self.timezone, forKey: "timezone")
        encoder.encodeObject(self.favorite_lists, forKey: "favorite_lists")
        encoder.encodeObject(self.fav_spot_id, forKey: "fav_spot_id")
        encoder.encodeObject(self.wind_desc, forKey: "wind_desc")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        if let spot_id = decoder.decodeObjectForKey("spot_id") as? Int {
            self.init(spot_id: spot_id)
        } else {
            return nil
        }
        name = decoder.decodeObjectForKey("name") as? String
        type = decoder.decodeObjectForKey("type") as? Int
        distance = decoder.decodeObjectForKey("distance") as? Double
        lat = decoder.decodeObjectForKey("lat") as? Double
        lon = decoder.decodeObjectForKey("lon") as? Double
        provider = decoder.decodeObjectForKey("provider") as? Int
        region_id = decoder.decodeObjectForKey("region_id") as? Int
        is_favorite = decoder.decodeObjectForKey("is_favorite") as? Bool
        wind_alert_exists = decoder.decodeObjectForKey("wind_alert_exists") as? Bool
        wind_alert_active = decoder.decodeObjectForKey("wind_alert_active") as? Bool
        upgrade_available = decoder.decodeObjectForKey("upgrade_available") as? Bool
        timestamp = decoder.decodeObjectForKey("timestamp") as? String
        avg = decoder.decodeObjectForKey("avg") as? Double
        lull = decoder.decodeObjectForKey("lull") as? Double
        gust = decoder.decodeObjectForKey("gust") as? Double
        dir = decoder.decodeObjectForKey("dir") as? Int
        dir_text = decoder.decodeObjectForKey("dir_text") as? String
        atemp = decoder.decodeObjectForKey("atemp") as? Double
        wtemp = decoder.decodeObjectForKey("wtemp") as? Double
        status = decoder.decodeObjectForKey("status") as? Status
        spot_message = decoder.decodeObjectForKey("spot_message") as? String
        source_message = decoder.decodeObjectForKey("source_message") as? String
        rank = decoder.decodeObjectForKey("rank") as? Double
        fav_sort_order = decoder.decodeObjectForKey("fav_sort_order") as? Int
        wave_height = decoder.decodeObjectForKey("wave_height") as? Double
        wave_period = decoder.decodeObjectForKey("wave_period") as? Double
        current_time_local = decoder.decodeObjectForKey("current_time_local") as? String
        pres = decoder.decodeObjectForKey("pres") as? Double
        timezone = decoder.decodeObjectForKey("timezone") as? String
        favorite_lists = decoder.decodeObjectForKey("favorite_lists") as? String
        fav_spot_id = decoder.decodeObjectForKey("fav_spot_id") as? Int
        wind_desc = decoder.decodeObjectForKey("wind_desc") as? String
    }
    
    public override var description: String {
        let description: String = "\(IntOrZero(self.spot_id)) \(self.name) %0.4f %0.4f"
        return "<\(self.dynamicType): \(self), \(description)>"
    }
    
    public var coordinate: CLLocationCoordinate2D {
        if let lat = self.lat, lon = self.lon {
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
            if CLLocationCoordinate2DIsValid(coordinate) {
                return coordinate
            }
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    public var title: String? {
        return self.name
    }
    
    public var subtitle: String? {
        return self.wind_desc
    }
    /*
    private var annotationView__: MKAnnotationView?
    public var annotationView: MKAnnotationView {
        if let view = self.annotationView__ {
            return view
        } else {
            var view: MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "SpotAnnotation")
            var windImage: UIImage?
            var windText: String? = nil
            if let avg = self.avg {
                if avg == 0.0 {
                    windImage = UIImage(named: "mapnowind.png")
                } else {
                    var live: Bool = (self.type == 1)
                    var color: UIColor = live ? UIColor.grayColor() : UIColor.lightGrayColor()
                    windImage = WeatherFlowApiSwift.windArrowWithSize(100.0, degrees: Float(DoubleOrZero(self.dir)), fillColor: color, strokeColor: color, text: "")
                    windText = String(format: "%0.0f", avg)
                }
            } else {
                windImage = UIImage(named: "mapnowindinfo.png")
            }
            
            var windImageView: UIImageView = UIImageView(image: windImage)
            windImageView.frame = CGRectMake(0, 0, 30, 30)
            view.addSubview(windImageView)
            var rect: CGRect = view.frame
            rect.size = windImageView.frame.size
            if let text = windText {
                var label: UILabel = UILabel()
                label.text = text
                label.textColor = UIColor.grayColor()
                label.backgroundColor = UIColor.clearColor()
                label.sizeToFit()
                var labelFrame: CGRect = label.frame
                labelFrame.origin.x = 30
                label.frame = labelFrame
                rect.size.width += labelFrame.size.width
                view.addSubview(label)
            }
            view.frame = rect
            //        view.image = windImage;
            view.canShowCallout = true
            var infoButton: UIButton = UIButton(type: .DetailDisclosure)
            view.rightCalloutAccessoryView = infoButton
            annotationView__ = view
            return view
        }
    }*/
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if !(object is Spot) {
            return false
        }
        let spot: Spot = object as! Spot
        return spot.spot_id == self.spot_id
    }
    
    public func distanceFrom(location: CLLocation) -> CLLocationDistance? {
        if CLLocationCoordinate2DIsValid(self.coordinate) {
            let loc: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let dist: CLLocationDistance = loc.distanceFromLocation(location)
            return dist
        }
        return nil
    }
    
    public func getModelData() -> ModelDataSet? {
        do {
            return try WeatherFlowApiSwift.getModelDataBySpot(self)
        } catch {
            return nil
        }
    }
    
    public func getModelDataError() throws -> ModelDataSet? {
        return try WeatherFlowApiSwift.getModelDataBySpot(self)
    }
}