//
//  Spot.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

#if os(OSX)
    import CoreLocation
#elseif os(Linux)
    import CoreLinuxLocation
#else
    import MapKit
#endif

open class Spot: NSObject {
    
    open fileprivate (set) var spot_id: Int
    open fileprivate (set) var name: String?
    open fileprivate (set) var type: Int?
    open fileprivate (set) var distance: Double?
    open fileprivate (set) var lat: Double?
    open fileprivate (set) var lon: Double?
    open fileprivate (set) var provider: Int?
    open fileprivate (set) var region_id: Int?
    open fileprivate (set) var is_favorite: Bool?
    open fileprivate (set) var wind_alert_exists: Bool?
    open fileprivate (set) var wind_alert_active: Bool?
    open fileprivate (set) var upgrade_available: Bool?
    open fileprivate (set) var timestamp: String?
    open fileprivate (set) var avg: Double?
    open fileprivate (set) var lull: Double?
    open fileprivate (set) var gust: Double?
    open fileprivate (set) var dir: Int?
    open fileprivate (set) var dir_text: String?
    open fileprivate (set) var atemp: Double?
    open fileprivate (set) var wtemp: Double?
    open fileprivate (set) var status: Status?
    open fileprivate (set) var spot_message: String?
    open fileprivate (set) var source_message: String?
    open fileprivate (set) var rank: Double?
    open fileprivate (set) var fav_sort_order: Int?
    open fileprivate (set) var wave_height: Double?
    open fileprivate (set) var wave_period: Double?
    open fileprivate (set) var current_time_local: String?
    open fileprivate (set) var pres: Double?
    open fileprivate (set) var timezone: String?
    open fileprivate (set) var favorite_lists: String?
    open fileprivate (set) var fav_spot_id: Int?
    open fileprivate (set) var wind_desc: String?

    public init(spot_id : Int) {
        self.spot_id = spot_id
        super.init()
    }
    
    public convenience init?(dictionary: [String : Any]) {
        if let spot_id = dictionary["spot_id"] as? Int {
            self.init(spot_id: spot_id)
        } else {
            return nil
        }
        if let isFav = BoolConverter.convert(dictionary["is_favorite"]) {
            print(isFav)
        }
        self.name = (dictionary["name"] as? String)
        self.type = (dictionary["type"] as? Int)
        self.distance = (dictionary["distance"] as? Double)
        self.lat = (dictionary["lat"] as? Double)
        self.lon = (dictionary["lon"] as? Double)
        self.provider = (dictionary["provider"] as? Int)
        self.region_id = (dictionary["region_id"] as? Int)
        self.is_favorite = BoolConverter.convert(dictionary["is_favorite"])
        self.wind_alert_exists = BoolConverter.convert(dictionary["wind_alert_exists"])
        self.wind_alert_active = BoolConverter.convert(dictionary["wind_alert_active"])
        self.upgrade_available = BoolConverter.convert(dictionary["upgrade_available"])
        self.timestamp = (dictionary["timestamp"] as? String)
        self.avg = (dictionary["avg"] as? Double)
        self.lull = (dictionary["lull"] as? Double)
        self.gust = (dictionary["gust"] as? Double)
        self.dir = (dictionary["dir"] as? Int)
        self.dir_text = (dictionary["dir_text"] as? String)
        self.atemp = (dictionary["atemp"] as? Double)
        self.wtemp = (dictionary["wtemp"] as? Double)
        if let statusDictionary = dictionary["status"] as? [String: Any] {
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
    
    func encodeWithCoder(_ encoder: NSCoder) {
        encoder.encode(self.spot_id, forKey: "spot_id")
        encoder.encode(self.name, forKey: "name")
        encoder.encode(self.type, forKey: "type")
        encoder.encode(self.distance, forKey: "distance")
        encoder.encode(self.lat, forKey: "lat")
        encoder.encode(self.lon, forKey: "lon")
        encoder.encode(self.provider, forKey: "provider")
        encoder.encode(self.region_id, forKey: "region_id")
        encoder.encode(self.is_favorite, forKey: "is_favorite")
        encoder.encode(self.wind_alert_exists, forKey: "wind_alert_exists")
        encoder.encode(self.wind_alert_active, forKey: "wind_alert_active")
        encoder.encode(self.upgrade_available, forKey: "upgrade_available")
        encoder.encode(self.timestamp, forKey: "timestamp")
        encoder.encode(self.avg, forKey: "avg")
        encoder.encode(self.lull, forKey: "lull")
        encoder.encode(self.gust, forKey: "gust")
        encoder.encode(self.dir, forKey: "dir")
        encoder.encode(self.dir_text, forKey: "dir_text")
        encoder.encode(self.atemp, forKey: "atemp")
        encoder.encode(self.wtemp, forKey: "wtemp")
        encoder.encode(self.status, forKey: "status")
        encoder.encode(self.spot_message, forKey: "spot_message")
        encoder.encode(self.source_message, forKey: "source_message")
        encoder.encode(self.rank, forKey: "rank")
        encoder.encode(self.fav_sort_order, forKey: "fav_sort_order")
        encoder.encode(self.wave_height, forKey: "wave_height")
        encoder.encode(self.wave_period, forKey: "wave_period")
        encoder.encode(self.current_time_local, forKey: "current_time_local")
        encoder.encode(self.pres, forKey: "pres")
        encoder.encode(self.timezone, forKey: "timezone")
        encoder.encode(self.favorite_lists, forKey: "favorite_lists")
        encoder.encode(self.fav_spot_id, forKey: "fav_spot_id")
        encoder.encode(self.wind_desc, forKey: "wind_desc")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        if let spot_id = decoder.decodeObject(forKey: "spot_id") as? Int {
            self.init(spot_id: spot_id)
        } else {
            return nil
        }
        name = decoder.decodeObject(forKey: "name") as? String
        type = decoder.decodeObject(forKey: "type") as? Int
        distance = decoder.decodeObject(forKey: "distance") as? Double
        lat = decoder.decodeObject(forKey: "lat") as? Double
        lon = decoder.decodeObject(forKey: "lon") as? Double
        provider = decoder.decodeObject(forKey: "provider") as? Int
        region_id = decoder.decodeObject(forKey: "region_id") as? Int
        is_favorite = decoder.decodeObject(forKey: "is_favorite") as? Bool
        wind_alert_exists = decoder.decodeObject(forKey: "wind_alert_exists") as? Bool
        wind_alert_active = decoder.decodeObject(forKey: "wind_alert_active") as? Bool
        upgrade_available = decoder.decodeObject(forKey: "upgrade_available") as? Bool
        timestamp = decoder.decodeObject(forKey: "timestamp") as? String
        avg = decoder.decodeObject(forKey: "avg") as? Double
        lull = decoder.decodeObject(forKey: "lull") as? Double
        gust = decoder.decodeObject(forKey: "gust") as? Double
        dir = decoder.decodeObject(forKey: "dir") as? Int
        dir_text = decoder.decodeObject(forKey: "dir_text") as? String
        atemp = decoder.decodeObject(forKey: "atemp") as? Double
        wtemp = decoder.decodeObject(forKey: "wtemp") as? Double
        status = decoder.decodeObject(forKey: "status") as? Status
        spot_message = decoder.decodeObject(forKey: "spot_message") as? String
        source_message = decoder.decodeObject(forKey: "source_message") as? String
        rank = decoder.decodeObject(forKey: "rank") as? Double
        fav_sort_order = decoder.decodeObject(forKey: "fav_sort_order") as? Int
        wave_height = decoder.decodeObject(forKey: "wave_height") as? Double
        wave_period = decoder.decodeObject(forKey: "wave_period") as? Double
        current_time_local = decoder.decodeObject(forKey: "current_time_local") as? String
        pres = decoder.decodeObject(forKey: "pres") as? Double
        timezone = decoder.decodeObject(forKey: "timezone") as? String
        favorite_lists = decoder.decodeObject(forKey: "favorite_lists") as? String
        fav_spot_id = decoder.decodeObject(forKey: "fav_spot_id") as? Int
        wind_desc = decoder.decodeObject(forKey: "wind_desc") as? String
    }
    
    open override var description: String {
        let description: String = "\(self.spot_id) \(self.name ?? "No Name") %0.4f %0.4f"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    
    open var coordinate: CLLocationCoordinate2D {
        if let lat = self.lat, let lon = self.lon {
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            if CLLocationCoordinate2DIsValid(coordinate) {
                return coordinate
            }
        }
        #if os(Linux)
            // TODO: We have to fix this some day and make it return nil
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        #else
            return kCLLocationCoordinate2DInvalid
        #endif
    }
    
    open var title: String? {
        return self.name
    }
    
    open var subtitle: String? {
        return self.wind_desc
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        if !(object is Spot) {
            return false
        }
        let spot: Spot = object as! Spot
        return spot.spot_id == self.spot_id
    }
    
    open func distanceFrom(_ location: CLLocation) -> CLLocationDistance? {
        if CLLocationCoordinate2DIsValid(self.coordinate) {
            let loc: CLLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let dist: CLLocationDistance = loc.distance(from: location)
            return dist
        }
        return nil
    }
    
    open func getModelData() -> ModelDataSet? {
        do {
            return try WeatherFlowApiSwift.getModelDataBySpot(self)
        } catch {
            return nil
        }
    }
    
    open func getModelDataError() throws -> ModelDataSet? {
        return try WeatherFlowApiSwift.getModelDataBySpot(self)
    }

    // THe following dictionary is used for storage on extensions like MKAnnotation
    open lazy var _extensionStorage = [String: Any]()
}

#if !os(OSX) && !os(Linux)
extension Spot: MKAnnotation {
    fileprivate var annotationView__: MKAnnotationView? {
        get {
            return self._extensionStorage["annotationView"] as? MKAnnotationView
        }
        set {
            self._extensionStorage["annotationView"] = newValue
        }
    }
    open var annotationView: MKAnnotationView {
        if let view = self.annotationView__ {
            return view
        } else {
            let view: MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "SpotAnnotation")
            var windImage: UIImage?
            var windText: String? = nil
            if let avg = self.avg {
                if avg == 0.0 {
                    windImage = UIImage(named: "mapnowind.png")
                } else {
                    let live: Bool = (self.type == 1)
                    let color: UIColor = live ? UIColor.gray : UIColor.lightGray
                    windImage = WeatherFlowApiSwift.windArrowWithSize(100.0, degrees: Float(self.dir ?? 0), fillColor: color, strokeColor: color, text: "")
                    windText = String(format: "%0.0f", avg)
                }
            } else {
                windImage = UIImage(named: "mapnowindinfo.png")
            }
            
            let windImageView: UIImageView = UIImageView(image: windImage)
            windImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            view.addSubview(windImageView)
            var rect: CGRect = view.frame
            rect.size = windImageView.frame.size
            if let text = windText {
                let label: UILabel = UILabel()
                label.text = text
                label.textColor = UIColor.gray
                label.backgroundColor = UIColor.clear
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
            let infoButton: UIButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = infoButton
            annotationView__ = view
            return view
        }
    }
}
#endif
