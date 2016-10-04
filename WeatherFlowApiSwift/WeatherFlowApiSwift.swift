//
//  WeatherFlowApiSwift.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 27/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation
import PazHelperSwift
import CoreLocation
import UIKit

enum WeatherFlowApiError: Error {
    case noResult
    case notInitialized
    case urlError
    case serverError(error: Error)
    case jSonError(error: Error?)
    case unknown
}

public enum WFUnitDistance : Int {
    case km
    case mi
    public static var allValues: [WFUnitDistance] {
        return [.km, .mi]
    }
    public var name: String {
        switch self {
        case .km:
            return "Klm"
        case .mi:
            return "Miles"
        }
    }
    public var parameter: String {
        switch self {
        case .km:
            return "km"
        case .mi:
            return "mi"
        }
    }
}

public enum WFUnitWind : Int {
    case mph
    case kts
    case kph
    case mps
    public static var allValues: [WFUnitWind] {
        return [.mph, .kts, .kph, .mps]
    }
    public var name: String {
        switch self {
        case .kph:
            return "Kph"
        case .kts:
            return "Kts"
        case .mph:
            return "Mph"
        case .mps:
            return "Mps"
        }
    }
    
    public var parameter: String {
        switch self {
        case .kph:
            return "kph"
        case .kts:
            return "kts"
        case .mph:
            return "mph"
        case .mps:
            return "mps"
        }
    }
}

public enum WFUnitTemp : Int {
    case c
    case f
    public static var allValues: [WFUnitTemp] {
        return [.c, .f]
    }
    public var name: String {
        switch self {
        case .f:
            return "F"
        case .c:
            return "C"
        }
    }
    
    public var parameter: String {
        switch self {
        case .f:
            return "f"
        case .c:
            return "c"
        }
    }
}

open class WeatherFlowApiSwift: NSObject {
    // MARK: Keys and Static Definitions
    static var api = "http://api.weatherflow.com"
    static var format = "json"
    static var DistanceKey = "WeatherFlowApiDistanceKey"
    static var UnitDistanceKey = "WeatherFlowApiUnitDistanceKey"
    static var UnitWindKey = "WeatherFlowApiUnitWindKey"
    static var UnitTempKey = "WeatherFlowApiUnitTempKey"
    static var IncludeWindSpeedOnArrowsKey = "IncludeWindSpeedOnArrowsKey"
    static var IncludeVirtualWeatherStationsKey = "IncludeVirtualWeatherStationsKey"
    
    static var NameKey = "Name"
    static var ValueKey = "Value"
    
    static var getTokenURL = "/wxengine/rest/session/getToken"
    static var getSpotSetBySearchURL = "/wxengine/rest/spot/getSpotSetBySearch"
    static var getSpotSetByLatLonURL = "/wxengine/rest/spot/getSpotSetByLatLon"
    static var getModelDataBySpotURL = "/wxengine/rest/model/getModelDataBySpot"
    static var getModelDataByLatLonURL = "/wxengine/rest/model/getModelDataByLatLon"
    static var getSpotSetByZoomLevelURL = "/wxengine/rest/spot/getSpotSetByZoomLevel"
    static var getSpotSetByListURL = "/wxengine/rest/spot/getSpotSetByList"
    static var getSpotStatsURL = "/wxengine/rest/stat/getSpotStats"
    static var getGraphURL = "/wxengine/rest/graph/getGraph"
    
    static var kArrowFillColor = "kArrowFillColor"
    static var kArrowStrokeColor = "kArrowStrokeColor"
    static var kArrowImage = "kArrowImage"
    static var kArrowSize = "kArrowSize"
    
    public enum UpdateNotification {
        case WeatherFlowApiToken
        case WeatherFlowRequestSent
        
        public var name: Notification.Name {
            switch self {
            case .WeatherFlowApiToken:
                return Notification.Name("kWeatherFlowApiTokenUpdateNotification")
            case .WeatherFlowRequestSent:
                return Notification.Name("WeatherFlowApiSwift.UpdateNotificationWeatherFlowRequestSent") // Used to monitor server requests
            }
        }
    }
    
    // MARK: - Units and Settings
    static open var unitDistance: WFUnitDistance {
        get {
            if let value = UserDefaults.standard.object(forKey: UnitDistanceKey) as? Int {
                if let unit = WFUnitDistance(rawValue: value) {
                    return unit
                }
            }
            return .km
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: self.UnitDistanceKey)
        }
    }
    
    static open var unitTemp: WFUnitTemp {
        get {
            if let value = UserDefaults.standard.object(forKey: self.UnitTempKey) as? Int {
                if let unit = WFUnitTemp(rawValue: value) {
                    return unit
                }
            }
            return .c
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: self.UnitTempKey)
        }
    }
    
    static open var unitWind: WFUnitWind {
        get {
            if let value = UserDefaults.standard.object(forKey: self.UnitWindKey) as? Int {
                if let unit = WFUnitWind(rawValue: value) {
                    return unit
                }
            }
            return .kts
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: self.UnitWindKey)
        }
    }
    
    open static var includeWindSpeedOnArrows: Bool {
        get {
            if let value = UserDefaults.standard.object(forKey: self.IncludeWindSpeedOnArrowsKey) as? Bool {
                return value
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.IncludeWindSpeedOnArrowsKey)
        }
    }
    
    open static var includeVirtualWeatherStations: Bool {
        get {
            if let value = UserDefaults.standard.object(forKey: self.IncludeVirtualWeatherStationsKey) as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.IncludeVirtualWeatherStationsKey)
        }
    }
    
    // MARK: - Session Data
    
    /// WeatherFlow api key. Used to authenticate with the server
    static open var apiKey: String?
    
    fileprivate static var session__: Session?
    fileprivate static var tokenRequestActive = false
    /// Session Information
    open static var session: Session? {
        if let session = self.session__ {
            return session
        }
        if self.tokenRequestActive == false {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {() -> Void in
                do {
                    let _ = try self.getToken()
                } catch {
                    print("Could not get token")
                }
            })
        }
        return nil
    }
    
    /// Indicates whether authentication with the server is active.
    static open var isReady: Bool {
        return self.session != nil
    }
    
    /// Connect to the server and request a new token. Nil for active request
    open class func getToken() throws -> Session? {
        // Print Sample Request
        if tokenRequestActive {
            return nil
        }
        if IntOrZero(self.apiKey?.length) == 0 {
            NSLog("Weather Token failed no api key")
            throw WeatherFlowApiError.notInitialized
        }
        tokenRequestActive = true
        NSLog("Requesting Weather Token")
        let urlString: String = "\(api)\(getTokenURL)\("?wf_apikey=")\(self.apiKey!)\("&format=")\(format)"

        do {
            defer {
                tokenRequestActive = false
            }
            let dictionary = try self.dictionaryFromURL(urlString)
            let session = Session(dictionary: dictionary)
            self.session__ = session
            NotificationCenter.default.post(name: WeatherFlowApiSwift.UpdateNotification.WeatherFlowApiToken.name, object: session__)
            NSLog("Weather Token Ready")
            return session
        }
    }
    
    // MARK: - Api Calls
    
    open class func getSpotSetBySearch(_ search: String, distance: Int) throws -> SpotSet {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.searchDictionaryWithValue(search))
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.formatDictionary)
        parameters.append(self.distanceDictionaryWithValue(distance))
        let urlString: String = self.urlForService(getSpotSetBySearchURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    open class func getSpotSetByLocation(_ location: CLLocationCoordinate2D, distance: Int) throws -> SpotSet {
        return try WeatherFlowApiSwift.getSpotSetByLocationCoordinate(location, distance: distance)
    }
    
    open class func getSpotSetByLocationCoordinate(_ location: CLLocationCoordinate2D, distance: Int) throws -> SpotSet {
        var parameters = [[AnyHashable: Any]]()
        parameters += self.locationArray(location)
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.distanceDictionaryWithValue(distance))
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getSpotSetByLatLonURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    open class func getSpotSetByZoomLevel(_ zoomLevel: Int, lat_min latMin: Float, lon_min lonMin: Float, lat_max latMax: Float, lon_max lonMax: Float) throws -> SpotSet {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.dictionaryWithParameter("lat_min", value: String(format: "%0.5f", latMin)))
        parameters.append(self.dictionaryWithParameter("lon_min", value: String(format: "%0.5f", lonMin)))
        parameters.append(self.dictionaryWithParameter("lat_max", value: String(format: "%0.5f", latMax)))
        parameters.append(self.dictionaryWithParameter("lon_max", value: String(format: "%0.5f", lonMax)))
        parameters.append(self.dictionaryWithParameter("zoom", value: "\(Int(zoomLevel))"))
        parameters += (self.unitsArray)
        parameters += (self.searchArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getSpotSetByZoomLevelURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    open class func getSpotSetByList(_ list: IndexSet) throws -> SpotSet {
        var parameters = [[AnyHashable: Any]]()
        parameters += (self.unitsArray)
        parameters.append(self.spotSetByListDictionaryWithValue(list))
        parameters.append(self.formatDictionary)
        parameters += self.searchArray
        let urlString: String = self.urlForService(getSpotSetByListURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    open class func getClosestSpotByLocation(_ location: CLLocationCoordinate2D, distance: Int) throws -> Spot? {
        let set: SpotSet = try self.getSpotSetByLocation(location, distance: distance)
        if set.status?.statusCode != 0 {
            return nil
        }
        for spot: Spot in set.spots {
            if spot.status?.statusCode == 0 && spot.avg != nil {
                return spot
            }
        }
        return nil
    }
    
    open class func getModelDataBySpot(_ spot: Spot) throws -> ModelDataSet? {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.spotIDDictionary(spot.spot_id))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet: ModelDataSet? = ModelDataSet(dictionary: dictionary, andSpot: spot)
        return modelDataSet
    }
    
    open class func getModelDataBySpotID(_ spotID: Int) throws -> ModelDataSet? {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.spotIDDictionary(spotID))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = ModelDataSet(dictionary: dictionary)
        return modelDataSet
    }
    
    open class func getModelDataByCoordinates(_ coordinate: CLLocationCoordinate2D) throws -> ModelDataSet? {
        var parameters = [[AnyHashable: Any]]()
        parameters += (self.locationArray(coordinate))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataByLatLonURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = ModelDataSet(dictionary: dictionary)
        return modelDataSet
    }

    open class func getSpotStatsBySpotID(_ spotID: Int, years: Int?) throws -> SpotStats? {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.spotIDDictionary(spotID))
//        parameters += (self.unitsArray)
        if let letYears = years {
            let yearsParam: [[AnyHashable: Any]] = [self.dictionaryWithParameter("years_back", value: "\(letYears)")]
            parameters += yearsParam
        }
        parameters += self.thresholdList
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getSpotStatsURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = SpotStats(spot_id: spotID, dictionary: dictionary)
        return modelDataSet
    }
    
    open class func getGraphForSpotID(_ spotID: Int, unitWind: WFUnitWind?) throws -> Graph {
        var parameters = [[AnyHashable: Any]]()
        parameters.append(self.spotIDDictionary(spotID))
        //        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        parameters += (self.searchArray)
        parameters.append(self.dictionaryWithParameter("show_virtual_obs", value: "true"))
        if let unitWind = unitWind {
            parameters.append(self.dictionaryWithParameter("units_wind", value: unitWind.parameter))

        } else {
            parameters.append(self.unitWindDictionary)
        }
        let urlString: String = self.urlForService(getGraphURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let graph = Graph(spot_id: spotID, dictionary: dictionary)
        return graph
        
    }

    // MARK: - UrlParameters Helpers
    open class func urlForService(_ service: String, andParameters parameters: [[AnyHashable: Any]]) -> String {
        var string = String()
        var token = ""
        if let letToken = self.session?.token {
            token = letToken
        }
        if let apiKey = self.apiKey {
            let urlPrefix: String = "\(api)\(service)?wf_apikey=\(apiKey)&wf_token=\(token)"
            string += urlPrefix
        }
        for dictionary: [AnyHashable: Any] in parameters {
            if let name = dictionary[NameKey], let value = dictionary[ValueKey] {
                let parametersString = String(format: "&%@=%@", arguments: [String(describing: name), String(describing: value)])
                string += parametersString
            }
        }
        return string
    }
    
    class var unitsArray: [[AnyHashable: Any]] {
        let array: [[AnyHashable: Any]] = [self.unitWindDictionary, self.unitDistanceDictionary, self.unitTempDictionary]
        return array
    }
    
    class var searchArray: [[AnyHashable: Any]] {
        if self.includeVirtualWeatherStations {
            return [self.dictionaryWithParameter("spot_types", value: "1,100,101")]
        }
        else {
            return [self.dictionaryWithParameter("spot_types", value: "1")]
        }
    }
    
    class var thresholdList: [[AnyHashable: Any]] {
        return [self.dictionaryWithParameter("threshold_list", value: "5,10,15,20,25")]
    }
    

    class func locationArray(_ location: CLLocationCoordinate2D) -> [[AnyHashable: Any]] {
        let lat: String = String(format: "%0.5f", location.latitude)
        let lon: String = String(format: "%0.5f", location.longitude)
        return [self.dictionaryWithParameter("lat", value: lat), self.dictionaryWithParameter("lon", value: lon)]
    }
    
    class func spotSetByListDictionaryWithValue(_ value: IndexSet) -> [AnyHashable: Any] {
        var string = String()
        for (_, value) in value.enumerated() {
            let spotId = String(format: "%lu", arguments: [UInt(value)])
            string += spotId
            string += ","
        }
        if string.characters.count > 0 {
            string.remove(at: string.characters.index(before: string.endIndex))
        }
        return self.dictionaryWithParameter("spot_list", value: string)
    }
    
    class func dictionaryWithParameter(_ name: String, value: String) -> [String : String] {
        return [self.NameKey: name, self.ValueKey: value]
    }
    
    class var unitWindDictionary: [String : String] {
        return self.dictionaryWithParameter("units_wind", value: self.unitWind.parameter)
    }
    
    class var unitTempDictionary: [String: String] {
        return self.dictionaryWithParameter("units_temp", value: self.unitTemp.parameter)
    }
    
    class var unitDistanceDictionary: [String: String] {
        return self.dictionaryWithParameter("units_distance", value: self.unitDistance.parameter)
    }
    
    class var formatDictionary: [String: String] {
        return self.dictionaryWithParameter("format", value: self.format)
    }
    
    class func searchDictionaryWithValue(_ value: String) -> [String: String] {
        return self.dictionaryWithParameter("search", value: value)
    }
    
    class func spotIDDictionary(_ spot_id: Int) -> [String: String] {
        return self.dictionaryWithParameter("spot_id", value: "\(Int(spot_id))")
    }
    
    class func distanceDictionaryWithValue(_ value: Int) -> [String: String] {
        return self.dictionaryWithParameter("search_dist", value: "\(Int(value))")
    }
    
    // JSON Helper
    class func dictionaryFromURL(_ urlString: String) throws -> [String: AnyObject] {
        let explode = urlString.explode("/")
        if explode.count > 5 {
            let requestString = explode[5]
            let explodeRequest = requestString.explode("?")
            if explodeRequest.count > 0 {
                let request = explodeRequest[0]
                NotificationCenter.default.post(name: WeatherFlowApiSwift.UpdateNotification.WeatherFlowRequestSent.name, object: self, userInfo: ["request" : request])
            }
        }
        if let url: URL = URL(string: urlString) {
            let (data, _, error) = URLSession.shared.synchronousDataTaskWithURL(url)
            
            if let result = data {
                let dictionary = try self.responseDictionaryFromJSONData(result)
                return dictionary
            } else {
                if let letError = error {
                    throw WeatherFlowApiError.serverError(error: letError)
                }
                throw WeatherFlowApiError.unknown
            }
        } else {
            throw WeatherFlowApiError.urlError
        }
    }
    
    class func responseDictionaryFromJSONData(_ data: Data) throws -> [String: AnyObject] {
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                return responseDictionary
            }
        } catch let error as NSError {
            throw WeatherFlowApiError.jSonError(error: error)
        }
        throw WeatherFlowApiError.jSonError(error: nil)
    }

    
    // MARK: - Graphics
    // TODO: Improve swift use
    static var arrowCache = [WeatherFlowArrowImage]()
    
    class func windArrowWithSize(_ size: Float) -> UIImage {
        let arrow: UIImage = self.windArrowWithSize(size, fillColor: UIColor.gray, strokeColor: UIColor.gray)
        return arrow
    }
    
    class func windArrowWithSize(_ size: Float, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        //Check for ready image in cache
        var cache = self.arrowCache.filter { (image) -> Bool in
            return image.fillColor == fillColor && image.strokeColor == strokeColor && image.size == Int(size)
        }
            
        if cache.count != 0 {
            let image = cache[0].image
            return image.copy() as! UIImage
        }
        NSLog("No cahce for size %f", size)
        // Get a bigger image for quality reasons
        let width: CGFloat = size.toCGFloat
        let height: CGFloat = size.toCGFloat
        // Prepare Points
        let arrowWidth: CGFloat = 0.5 * width
        let buttonLeftPoint: CGPoint = CGPoint(x: (width - arrowWidth) / 2.0, y: height * 0.9)
        let buttonRightPoint: CGPoint = CGPoint(x: buttonLeftPoint.x + arrowWidth, y: height * 0.9)
        let topArrowPoint: CGPoint = CGPoint(x: width / 2.0, y: 0.0)
        let buttomMiddlePoint: CGPoint = CGPoint(x: width / 2.0, y: 0.7 * height)
        // Start Context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // Prepare context parameters
        context.setLineWidth(1)
        context.setStrokeColor(strokeColor.cgColor)
        context.setFillColor(fillColor.cgColor)
        let pathRef: CGMutablePath = CGMutablePath()
        pathRef.move(to: CGPoint(x: topArrowPoint.x, y: topArrowPoint.y))
        pathRef.addLine(to: CGPoint(x: buttonLeftPoint.x, y: buttonLeftPoint.y))
        pathRef.addLine(to: CGPoint(x: buttomMiddlePoint.x, y: buttomMiddlePoint.y))
        pathRef.addLine(to: CGPoint(x: buttonRightPoint.x, y: buttonRightPoint.y))
        pathRef.addLine(to: CGPoint(x: topArrowPoint.x, y: topArrowPoint.y))
        pathRef.closeSubpath()
        context.addPath(pathRef)
        context.fillPath()
        context.addPath(pathRef)
        context.strokePath()
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Resize image.
        let newImage = WeatherFlowArrowImage(fillColor: fillColor, strokeColor: strokeColor, size: Int(size), image: i.copy() as! UIImage)
        self.arrowCache.append(newImage)
        return i
    }
    
    class func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        if image.size.equalTo(size) {
            return image
        }
        NSLog("Resize")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 0.0)
        // Set the quality level to use when rescaling
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func windArrowWithSize(_ size: Float, degrees: Float, fillColor: UIColor, strokeColor: UIColor, text: String) -> UIImage {
        let image: UIImage = self.windArrowWithSize(size, fillColor: fillColor, strokeColor: strokeColor)
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Resize
        //i = [self resizeImage:i to:CGSizeMake(size, size)];
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func windArrowWithText(_ text: String, degrees: Float) -> UIImage {
        let image: UIImage = self.windArrowWithSize(30.0)
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func waveArrowWithText(_ text: String, degrees: Float) -> UIImage {
        let image: UIImage = self.windArrowWithSize(30, fillColor: UIColor.blue, strokeColor: UIColor.blue)
        // Create image
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        return self.addText(text, toImage: i)
    }
    
    class func addText(_ text: String?, toImage image: UIImage) -> UIImage {
        guard let text = text , text.length != 0 else {
            return image
        }
        let font: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
        let constrainSize: CGSize = CGSize(width: 30, height: image.size.height)
        let string = text as NSString
        var stringSize: CGSize = string.size(attributes: [NSFontAttributeName: font])
        stringSize = CGSize(width: min(constrainSize.width, stringSize.width), height: min(constrainSize.height, stringSize.height))
        let size: CGSize = CGSize(width: image.size.width + stringSize.width, height: max(image.size.height, stringSize.height))
        UIGraphicsBeginImageContext(size)
        // Draw image
        UIGraphicsGetCurrentContext()?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        // Draw Text
        UIGraphicsGetCurrentContext()?.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let renderingRect: CGRect = CGRect(x: image.size.width, y: 0, width: stringSize.width, height: stringSize.height)
        
        /// Make a copy of the default paragraph style
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakMode.byCharWrapping
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignment.left
        
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle] as [String : Any]

        string.draw(in: renderingRect, withAttributes: attributes)
        
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return i
    }
    
    class func rotatedImage(_ image: UIImage, degrees: Float) -> UIImage {
        // We add 180 to callibrate the arrow and then conver to radians.
        let rads: CGFloat = degrees.toCGFloat * (M_PI / 180.0)
        let newSide: CGFloat = max(image.size.width, image.size.height)
        // Start Context
        let size: CGSize = CGSize(width: newSide, height: newSide)
        UIGraphicsBeginImageContext(size)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: newSide / 2, y: newSide / 2)
        ctx.rotate(by: rads)
        UIGraphicsGetCurrentContext()?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: size.width, height: size.height))
        // Create image
        let i: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return i
    }
}

struct WeatherFlowArrowImage {
    var fillColor: UIColor
    var strokeColor: UIColor
    var size: Int
    var image: UIImage
}

