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

enum WeatherFlowApiError: ErrorType {
    case NoResult
    case NotInitialized
    case URLError
    case ServerError(error: NSError)
    case JSonError(error: NSError?)
    case Unknown
}

public enum WFUnitDistance : Int {
    case Km
    case Mi
    public static var allValues: [WFUnitDistance] {
        return [.Km, .Mi]
    }
    public var name: String {
        switch self {
        case .Km:
            return "Klm"
        case .Mi:
            return "Miles"
        }
    }
    public var parameter: String {
        switch self {
        case .Km:
            return "km"
        case .Mi:
            return "mi"
        }
    }
}

public enum WFUnitWind : Int {
    case Mph
    case Kts
    case Kph
    case Mps
    public static var allValues: [WFUnitWind] {
        return [.Mph, .Kts, .Kph, .Mps]
    }
    public var name: String {
        switch self {
        case .Kph:
            return "Kph"
        case .Kts:
            return "Kts"
        case .Mph:
            return "Mph"
        case .Mps:
            return "Mps"
        }
    }
    
    public var parameter: String {
        switch self {
        case .Kph:
            return "kph"
        case .Kts:
            return "kts"
        case .Mph:
            return "mph"
        case .Mps:
            return "mps"
        }
    }
}

public enum WFUnitTemp : Int {
    case C
    case F
    public static var allValues: [WFUnitTemp] {
        return [.C, .F]
    }
    public var name: String {
        switch self {
        case .F:
            return "F"
        case .C:
            return "C"
        }
    }
    
    public var parameter: String {
        switch self {
        case .F:
            return "f"
        case .C:
            return "c"
        }
    }
}

public class WeatherFlowApiSwift: NSObject {
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
    
    public static var UpdateNotificationWeatherFlowApiToken = "kWeatherFlowApiTokenUpdateNotification"
    public static var UpdateNotificationWeatherFlowRequestSent = "WeatherFlowApiSwift.UpdateNotificationWeatherFlowRequestSent" // Used to monitor server requests
    
    // MARK: - Units and Settings
    static public var unitDistance: WFUnitDistance {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(UnitDistanceKey) as? Int {
                if let unit = WFUnitDistance(rawValue: value) {
                    return unit
                }
            }
            return .Km
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: self.UnitDistanceKey)
        }
    }
    
    static public var unitTemp: WFUnitTemp {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(self.UnitTempKey) as? Int {
                if let unit = WFUnitTemp(rawValue: value) {
                    return unit
                }
            }
            return .C
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: self.UnitTempKey)
        }
    }
    
    static public var unitWind: WFUnitWind {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(self.UnitWindKey) as? Int {
                if let unit = WFUnitWind(rawValue: value) {
                    return unit
                }
            }
            return .Kts
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: self.UnitWindKey)
        }
    }
    
    public static var includeWindSpeedOnArrows: Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(self.IncludeWindSpeedOnArrowsKey) as? Bool {
                return value
            }
            return true
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: self.IncludeWindSpeedOnArrowsKey)
        }
    }
    
    public static var includeVirtualWeatherStations: Bool {
        get {
            if let value = NSUserDefaults.standardUserDefaults().objectForKey(self.IncludeVirtualWeatherStationsKey) as? Bool {
                return value
            }
            return false
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: self.IncludeVirtualWeatherStationsKey)
        }
    }
    
    // MARK: - Session Data
    
    /// WeatherFlow api key. Used to authenticate with the server
    static public var apiKey: String?
    
    private static var session__: Session?
    private static var tokenRequestActive = false
    /// Session Information
    public static var session: Session? {
        if let session = self.session__ {
            return session
        }
        if self.tokenRequestActive == false {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                do {
                    try self.getToken()
                } catch {
                    print("Could not get token")
                }
            })
        }
        return nil
    }
    
    /// Indicates whether authentication with the server is active.
    static public var isReady: Bool {
        return self.session != nil
    }
    
    /// Connect to the server and request a new token. Nil for active request
    public class func getToken() throws -> Session? {
        // Print Sample Request
        if tokenRequestActive {
            return nil
        }
        if IntOrZero(self.apiKey?.length) == 0 {
            NSLog("Weather Token failed no api key")
            throw WeatherFlowApiError.NotInitialized
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
            NSNotificationCenter.defaultCenter().postNotificationName(self.UpdateNotificationWeatherFlowApiToken, object: session__)
            NSLog("Weather Token Ready")
            return session
        }
    }
    
    // MARK: - Api Calls
    
    public class func getSpotSetBySearch(search: String, distance: Int) throws -> SpotSet {
        var parameters = [[NSObject: AnyObject]]()
        parameters.append(self.searchDictionaryWithValue(search))
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.formatDictionary)
        parameters.append(self.distanceDictionaryWithValue(distance))
        let urlString: String = self.urlForService(getSpotSetBySearchURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    public class func getSpotSetByLocation(location: CLLocationCoordinate2D, distance: Int) throws -> SpotSet {
        return try WeatherFlowApiSwift.getSpotSetByLocationCoordinate(location, distance: distance)
    }
    
    public class func getSpotSetByLocationCoordinate(location: CLLocationCoordinate2D, distance: Int) throws -> SpotSet {
        var parameters = [[NSObject: AnyObject]]()
        parameters += self.locationArray(location)
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.distanceDictionaryWithValue(distance))
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getSpotSetByLatLonURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    public class func getSpotSetByZoomLevel(zoomLevel: Int, lat_min latMin: Float, lon_min lonMin: Float, lat_max latMax: Float, lon_max lonMax: Float) throws -> SpotSet {
        var parameters = [[NSObject: AnyObject]]()
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
    
    public class func getSpotSetByList(list: NSIndexSet) throws -> SpotSet {
        var parameters = [[NSObject: AnyObject]]()
        parameters += (self.unitsArray)
        parameters.append(self.spotSetByListDictionaryWithValue(list))
        parameters.append(self.formatDictionary)
        parameters += self.searchArray
        let urlString: String = self.urlForService(getSpotSetByListURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        return SpotSet(dictionary: dictionary)
    }
    
    public class func getClosestSpotByLocation(location: CLLocationCoordinate2D, distance: Int) throws -> Spot? {
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
    
    public class func getModelDataBySpot(spot: Spot) throws -> ModelDataSet? {
        var parameters = [[NSObject: AnyObject]]()
        parameters.append(self.spotIDDictionary(spot.spot_id))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet: ModelDataSet? = ModelDataSet(dictionary: dictionary, andSpot: spot)
        return modelDataSet
    }
    
    public class func getModelDataBySpotID(spotID: Int) throws -> ModelDataSet? {
        var parameters = [[NSObject: AnyObject]]()
        parameters.append(self.spotIDDictionary(spotID))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = ModelDataSet(dictionary: dictionary)
        return modelDataSet
    }
    
    public class func getModelDataByCoordinates(coordinate: CLLocationCoordinate2D) throws -> ModelDataSet? {
        var parameters = [[NSObject: AnyObject]]()
        parameters += (self.locationArray(coordinate))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getModelDataByLatLonURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = ModelDataSet(dictionary: dictionary)
        return modelDataSet
    }

    public class func getSpotStatsBySpotID(spotID: Int, years: Int?) throws -> SpotStats? {
        var parameters = [[NSObject: AnyObject]]()
        parameters.append(self.spotIDDictionary(spotID))
//        parameters += (self.unitsArray)
        if let letYears = years {
            let yearsParam: [[NSObject: AnyObject]] = [self.dictionaryWithParameter("years_back", value: "\(letYears)")]
            parameters += yearsParam
        }
        parameters += self.thresholdList
        parameters.append(self.formatDictionary)
        let urlString: String = self.urlForService(getSpotStatsURL, andParameters: parameters)
        let dictionary = try self.dictionaryFromURL(urlString)
        let modelDataSet = SpotStats(spot_id: spotID, dictionary: dictionary)
        return modelDataSet
    }
    
    public class func getGraphForSpotID(spotID: Int, unitWind: WFUnitWind?) throws -> Graph {
        var parameters = [[NSObject: AnyObject]]()
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
    public class func urlForService(service: String, andParameters parameters: [[NSObject: AnyObject]]) -> String {
        var string = String()
        var token = ""
        if let letToken = self.session?.token {
            token = letToken
        }
        if let apiKey = self.apiKey {
            let urlPrefix: String = "\(api)\(service)?wf_apikey=\(apiKey)&wf_token=\(token)"
            string += urlPrefix
        }
        for dictionary: [NSObject : AnyObject] in parameters {
            if let name = dictionary[NameKey], value = dictionary[ValueKey] {
                let parametersString = String(format: "&%@=%@", arguments: [String(name), String(value)])
                string += parametersString
            }
        }
        return string
    }
    
    class var unitsArray: [[NSObject: AnyObject]] {
        let array: [[NSObject: AnyObject]] = [self.unitWindDictionary, self.unitDistanceDictionary, self.unitTempDictionary]
        return array
    }
    
    class var searchArray: [[NSObject: AnyObject]] {
        if self.includeVirtualWeatherStations {
            return [self.dictionaryWithParameter("spot_types", value: "1,100,101")]
        }
        else {
            return [self.dictionaryWithParameter("spot_types", value: "1")]
        }
    }
    
    class var thresholdList: [[NSObject: AnyObject]] {
        return [self.dictionaryWithParameter("threshold_list", value: "5,10,15,20,25")]
    }
    

    class func locationArray(location: CLLocationCoordinate2D) -> [[NSObject: AnyObject]] {
        let lat: String = String(format: "%0.5f", location.latitude)
        let lon: String = String(format: "%0.5f", location.longitude)
        return [self.dictionaryWithParameter("lat", value: lat), self.dictionaryWithParameter("lon", value: lon)]
    }
    
    class func spotSetByListDictionaryWithValue(value: NSIndexSet) -> [NSObject : AnyObject] {
        var string = String()
        value.enumerateIndexesUsingBlock { (idx, stop) -> Void in
            let spotId = String(format: "%lu", arguments: [UInt(idx)])
            string += spotId
            string += ","
        }
        if string.characters.count > 0 {
            string.removeAtIndex(string.endIndex.predecessor())
        }
        return self.dictionaryWithParameter("spot_list", value: string)
    }
    
    class func dictionaryWithParameter(name: String, value: String) -> [String : String] {
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
    
    class func searchDictionaryWithValue(value: String) -> [String: String] {
        return self.dictionaryWithParameter("search", value: value)
    }
    
    class func spotIDDictionary(spot_id: Int) -> [String: String] {
        return self.dictionaryWithParameter("spot_id", value: "\(Int(spot_id))")
    }
    
    class func distanceDictionaryWithValue(value: Int) -> [String: String] {
        return self.dictionaryWithParameter("search_dist", value: "\(Int(value))")
    }
    
    // JSON Helper
    class func dictionaryFromURL(urlString: String) throws -> [String: AnyObject] {
        let explode = urlString.explode("/")
        if explode.count > 5 {
            let requestString = explode[5]
            let explodeRequest = requestString.explode("?")
            if explodeRequest.count > 0 {
                let request = explodeRequest[0]
                NSNotificationCenter.defaultCenter().postNotificationName(WeatherFlowApiSwift.UpdateNotificationWeatherFlowRequestSent, object: self, userInfo: ["request" : request])
            }
        }
        if let url: NSURL = NSURL(string: urlString) {
            let (data, _, error) = NSURLSession.sharedSession().synchronousDataTaskWithURL(url)
            
            if let result = data {
                let dictionary = try self.responseDictionaryFromJSONData(result)
                return dictionary
            } else {
                if let letError = error {
                    throw WeatherFlowApiError.ServerError(error: letError)
                }
                throw WeatherFlowApiError.Unknown
            }
        } else {
            throw WeatherFlowApiError.URLError
        }
    }
    
    class func responseDictionaryFromJSONData(data: NSData) throws -> [String: AnyObject] {
        do {
            if let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                return responseDictionary
            }
        } catch let error as NSError {
            throw WeatherFlowApiError.JSonError(error: error)
        }
        throw WeatherFlowApiError.JSonError(error: nil)
    }

    
    // MARK: - Graphics
    /*
    // TODO: Improve swift use
    static var arrowCache = [String: AnyObject]()
    
    class func windArrowWithSize(size: Float) -> UIImage {
        let arrow: UIImage = self.windArrowWithSize(size, fillColor: UIColor.grayColor(), strokeColor: UIColor.grayColor())
        return arrow
    }
    
    class func windArrowWithSize(size: Float, fillColor: UIColor, strokeColor: UIColor) -> UIImage {
        //Check for ready image in cache
        var predicate: NSPredicate = NSPredicate(format: "%K == %@ AND %K == %@ AND %K == %f", kArrowFillColor, fillColor, kArrowStrokeColor, strokeColor, kArrowSize, size)
        var cache: [AnyObject] = self.arrowCache.filteredArrayUsingPredicate(predicate)
        if cache.count != 0 {
            var image: UIImage = (cache[0][kArrowImage] as! UIImage)
            return image.copy()
        }
        NSLog("No cahce for size %f", size)
        // Get a bigger image for quality reasons
        var width: Float = size
        var height: Float = size
        // Prepare Points
        var arrowWidth: Float = 0.5 * width
        var buttonLeftPoint: CGPoint = CGPointMake((width - arrowWidth) / 2.0, height * 0.9)
        var buttonRightPoint: CGPoint = CGPointMake(buttonLeftPoint.x + arrowWidth, height * 0.9)
        var topArrowPoint: CGPoint = CGPointMake(width / 2.0, 0.0)
        var buttomMiddlePoint: CGPoint = CGPointMake(width / 2.0, 0.7 * height)
        // Start Context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 0.0)
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        // Prepare context parameters
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        var pathRef: CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(pathRef, nil, topArrowPoint.x, topArrowPoint.y)
        CGPathAddLineToPoint(pathRef, nil, buttonLeftPoint.x, buttonLeftPoint.y)
        CGPathAddLineToPoint(pathRef, nil, buttomMiddlePoint.x, buttomMiddlePoint.y)
        CGPathAddLineToPoint(pathRef, nil, buttonRightPoint.x, buttonRightPoint.y)
        CGPathAddLineToPoint(pathRef, nil, topArrowPoint.x, topArrowPoint.y)
        CGPathCloseSubpath(pathRef)
        CGContextAddPath(context, pathRef)
        CGContextFillPath(context)
        CGContextAddPath(context, pathRef)
        CGContextStrokePath(context)
        var i: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Resize image.
        self.arrowCache.append([
            kArrowFillColor : fillColor,
            kArrowStrokeColor : strokeColor,
            kArrowSize : Int(size),
            kArrowImage : i.copy()
            ]
        )
        return i
        //[self resizeImage:i to:CGSizeMake(size, size)];
    }
    
    class func resizeImage(image: UIImage, to size: CGSize) -> UIImage {
        if CGSizeEqualToSize(image.size, size) {
            return image
        }
        NSLog("Resize")
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), false, 0.0)
        // Set the quality level to use when rescaling
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func windArrowWithSize(size: Float, degrees: Float, fillColor: UIColor, strokeColor: UIColor, text: String) -> UIImage {
        var image: UIImage = self.windArrowWithSize(size, fillColor: fillColor, strokeColor: strokeColor)
        var i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Resize
        //i = [self resizeImage:i to:CGSizeMake(size, size)];
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func windArrowWithText(text: String, degrees: Float) -> UIImage {
        var image: UIImage = self.windArrowWithSize(30.0)
        var i: UIImage = self.rotatedImage(image, degrees: degrees)
        // Add Text
        return self.addText(text, toImage: i)
    }
    
    class func waveArrowWithText(text: String, degrees: Float) -> UIImage {
        let image: UIImage = self.windArrowWithSize(30, fillColor: UIColor.blueColor(), strokeColor: UIColor.blueColor())
        // Create image
        let i: UIImage = self.rotatedImage(image, degrees: degrees)
        return self.addText(text, toImage: i)
    }
    
    class func addText(text: String, toImage image: UIImage) -> UIImage {
        if !text || text.length == 0 {
            return image
        }
        var font: UIFont = UIFont.boldSystemFontOfSize(14.0)
        var constrainSize: CGSize = CGSizeMake(30, image.size.height)
        var stringSize: CGSize = text.sizeWithFont(font, constrainedToSize: constrainSize, lineBreakMode: NSLineBreakMode.ByCharWrapping)
        var size: CGSize = CGSizeMake(image.size.width + stringSize.width, max(image.size.height, stringSize.height))
        UIGraphicsBeginImageContext(size)
        // Draw image
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
        // Draw Text
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0)
        var renderingRect: CGRect = CGRectMake(image.size.width, 0, stringSize.width, stringSize.height)
        text.drawInRect(renderingRect, withFont: font, lineBreakMode: NSLineBreakMode.ByCharWrapping, alignment: .Left)
        var i: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return i
    }
    
    class func rotatedImage(image: UIImage, degrees: Float) -> UIImage {
        // We add 180 to callibrate the arrow and then conver to radians.
        var rads: Float = degrees * (M_PI / 180.0)
        var newSide: Float = max(image.size().width, image.size().height)
        // Start Context
        var size: CGSize = CGSizeMake(newSide, newSide)
        UIGraphicsBeginImageContext(size)
        var ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(ctx, newSide / 2, newSide / 2)
        CGContextRotateCTM(ctx, rads)
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-image.size().width / 2, -image.size().height / 2, size.width, size.height), image.CGImage)
        // Create image
        var i: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return i
    }*/
}

