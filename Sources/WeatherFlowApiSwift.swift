//
//  WeatherFlowApiSwift.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 27/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
    import CoreLinuxLocation
#else
    import CoreLocation
#endif


public enum WeatherFlowApiError: Error {
    case noResult
    case notInitialized
    case urlError
    case serverError(error: Error)
    case jSonError(error: Error?)
    case duplicateRequest
    case unknown
}

public enum WeatherFlowApiResult<T> {
    case success(T)
    case error(error: WeatherFlowApiError)
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

public typealias WFParameters = [[AnyHashable: Any]]
public typealias SpotSetCompletion = (WeatherFlowApiResult<SpotSet>) -> Void
public typealias SpotCompletion = (WeatherFlowApiResult<Spot?>) -> Void
public typealias ModelDataSetCompletion = (WeatherFlowApiResult<ModelDataSet?>) -> Void
// TODO: Add when SpotStats is codable public typealias SpotStatsCompletion = (WeatherFlowApiResult<SpotStats?>) -> Void
public typealias GraphCompletion = (WeatherFlowApiResult<Graph>) -> Void

open class WeatherFlowApiSwift {
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
                return Notification.Name(rawValue: "kWeatherFlowApiTokenUpdateNotification")
            case .WeatherFlowRequestSent:
                return Notification.Name(rawValue: "WeatherFlowApiSwift.UpdateNotificationWeatherFlowRequestSent") // Used to monitor server requests
            }
        }
    }
    
    static open var urlSession: URLSession = URLSession.shared
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        #if !os(Linux)
            DateFormatter.defaultFormatterBehavior = DateFormatter.Behavior.default
        #endif
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        return dateFormatter
    }()
    
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
    
    fileprivate static var session__: Session? {
        didSet {
            NotificationCenter.default.post(name: WeatherFlowApiSwift.UpdateNotification.WeatherFlowApiToken.name, object: self.session__)
            NSLog("Weather Token Ready")
        }
    }
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
    
    /// Connect to the server and request a new token. Nil for active request (sync)
    open class func getToken() throws -> Session? {
        // Print Sample Request
        if tokenRequestActive {
            throw WeatherFlowApiError.duplicateRequest
        }
        if (self.apiKey?.count ?? 0) == 0 {
            NSLog("Weather Token failed no api key")
            throw WeatherFlowApiError.notInitialized
        }
        tokenRequestActive = true
        NSLog("Requesting Weather Token")
        let urlString = self.tokenUrlString

        do {
            defer {
                tokenRequestActive = false
            }
            let data = try self.dataFromURL(urlString)
            let session = try Session(data: data)
            self.session__ = session
            return session
        }
    }

    /// Connect to the server and request a new token. Nil for active request (async)
    open class func getToken(completion: @escaping (WeatherFlowApiResult<Session>) -> Void) {
        // Print Sample Request
        if tokenRequestActive {
            return completion(.error(error: .duplicateRequest))
        }
        if (self.apiKey?.count ?? 0) == 0 {
            print("Weather Token failed no api key")
            return completion(.error(error: WeatherFlowApiError.notInitialized))
        }
        tokenRequestActive = true
        NSLog("Requesting Weather Token")
        let urlString = self.tokenUrlString
        
        self.dataFromURL(urlString) { (result) in
            defer {
                tokenRequestActive = false
            }
            switch result {
            case .success(let data):
                do {
                    let session = try Session(data: data)
                    self.session__ = session
                    return completion(.success(session))
                } catch  {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
            
        }
    }
    
    class var tokenUrlString: String {
        let urlString: String = "\(api)\(getTokenURL)\("?wf_apikey=")\(self.apiKey!)\("&format=")\(format)"
        return urlString
    }

    // MARK: - Api Calls
 
    // Spot Set By Search
    class func parametersForSpotSetBySearch(_ search: String, distance: Int) -> WFParameters {
        var parameters = WFParameters()
        parameters.append(self.searchDictionaryWithValue(search))
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.formatDictionary)
        parameters.append(self.distanceDictionaryWithValue(distance))
        return parameters
    }
    
    open class func getSpotSetBySearch(_ search: String, distance: Int) throws -> SpotSet {
        let parameters = self.parametersForSpotSetBySearch(search, distance: distance)
        let urlString: String = self.urlForService(getSpotSetBySearchURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        return try SpotSet(data: data)
    }

    open class func getSpotSetBySearch(_ search: String, distance: Int, completion: @escaping SpotSetCompletion) {
        let parameters = self.parametersForSpotSetBySearch(search, distance: distance)
        let urlString: String = self.urlForService(getSpotSetBySearchURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let spotSet = try SpotSet(data: data)
                    return completion(.success(spotSet))
                } catch {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }
    
    // Spot Set By Location Coordinate
    class func parametersForSpotSetByLocationCoordinate(_ coordinate: CLLocationCoordinate2D, distance: Int) -> WFParameters {
        var parameters = WFParameters()
        parameters += self.coordinateArray(coordinate)
        parameters += self.unitsArray
        parameters += self.searchArray
        parameters.append(self.distanceDictionaryWithValue(distance))
        parameters.append(self.formatDictionary)
        return parameters
    }
    
    open class func getSpotSetByCoordinate(_ coordinate: CLLocationCoordinate2D, distance: Int) throws -> SpotSet {
        let parameters = self.parametersForSpotSetByLocationCoordinate(coordinate, distance: distance)
        let urlString: String = self.urlForService(getSpotSetByLatLonURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        return try SpotSet(data: data)
    }

    open class func getSpotSetByCoordinate(_ coordinate: CLLocationCoordinate2D, distance: Int, completion: @escaping SpotSetCompletion) {
        let parameters = self.parametersForSpotSetByLocationCoordinate(coordinate, distance: distance)
        let urlString: String = self.urlForService(getSpotSetByLatLonURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let spotSet = try SpotSet(data: data)
                    return completion(.success(spotSet))
                } catch {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }
    
    // Spot Set By Zoom Level
    class func parametersForSpotSetByZoomLevel(_ zoomLevel: Int, lat_min latMin: Float, lon_min lonMin: Float, lat_max latMax: Float, lon_max lonMax: Float) -> WFParameters {
        var parameters = WFParameters()
        parameters.append(self.dictionaryWithParameter("lat_min", value: String(format: "%0.5f", latMin)))
        parameters.append(self.dictionaryWithParameter("lon_min", value: String(format: "%0.5f", lonMin)))
        parameters.append(self.dictionaryWithParameter("lat_max", value: String(format: "%0.5f", latMax)))
        parameters.append(self.dictionaryWithParameter("lon_max", value: String(format: "%0.5f", lonMax)))
        parameters.append(self.dictionaryWithParameter("zoom", value: "\(Int(zoomLevel))"))
        parameters += (self.unitsArray)
        parameters += (self.searchArray)
        parameters.append(self.formatDictionary)
        return parameters
    }
    
    open class func getSpotSetByZoomLevel(_ zoomLevel: Int, lat_min latMin: Float, lon_min lonMin: Float, lat_max latMax: Float, lon_max lonMax: Float) throws -> SpotSet {
        let parameters = self.parametersForSpotSetByZoomLevel(zoomLevel, lat_min: latMin, lon_min: lonMin, lat_max: latMax, lon_max: lonMax)
        let urlString: String = self.urlForService(getSpotSetByZoomLevelURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        return try SpotSet(data: data)
    }

    open class func getSpotSetByZoomLevel(_ zoomLevel: Int, lat_min latMin: Float, lon_min lonMin: Float, lat_max latMax: Float, lon_max lonMax: Float, completion: @escaping SpotSetCompletion) {
        let parameters = self.parametersForSpotSetByZoomLevel(zoomLevel, lat_min: latMin, lon_min: lonMin, lat_max: latMax, lon_max: lonMax)
        let urlString: String = self.urlForService(getSpotSetByZoomLevelURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let spotSet = try SpotSet(data: data)
                    return completion(.success(spotSet))
                } catch  {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Spot Set By List
    class func parametersForSpotSetByList(list: IndexSet) -> WFParameters {
        var parameters = WFParameters()
        parameters += (self.unitsArray)
        parameters.append(self.spotSetByListDictionaryWithValue(list))
        parameters.append(self.formatDictionary)
        parameters += self.searchArray
        return parameters
    }
    
    open class func getSpotSetByList(_ list: IndexSet) throws -> SpotSet {
        let parameters = self.parametersForSpotSetByList(list: list)
        let urlString: String = self.urlForService(getSpotSetByListURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        return try SpotSet(data: data)
    }

    open class func getSpotSetByList(_ list: IndexSet, completion: @escaping SpotSetCompletion) {
        let parameters = self.parametersForSpotSetByList(list: list)
        let urlString: String = self.urlForService(getSpotSetByListURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let spotSet = try SpotSet(data: data)
                    return completion(.success(spotSet))
                } catch {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Closest Spot By Coordinate
    open class func getClosestSpotByCoordinate(_ coordinate: CLLocationCoordinate2D, distance: Int) throws -> Spot? {
        let set: SpotSet = try self.getSpotSetByCoordinate(coordinate, distance: distance)
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

    open class func getClosestSpotByCoordinate(_ coordinate: CLLocationCoordinate2D, distance: Int, completion: @escaping SpotCompletion) {
        self.getSpotSetByCoordinate(coordinate, distance: distance) { (result) in
            switch result {
            case .success(let set):
                if set.status?.statusCode != 0 {
                    return completion(.success(nil))
                }
                for spot: Spot in set.spots {
                    if spot.status?.statusCode == 0 && spot.avg != nil {
                        return completion(.success(spot))
                    }
                }
                return completion(.success(nil))
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Model Data Set By Spot
    class func parametersForModelDataBySpot(_ spot: Spot) -> WFParameters {
        var parameters = WFParameters()
        parameters.append(self.spotIDDictionary(spot.spotId))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        return parameters
    }
    
    open class func getModelDataBySpot(_ spot: Spot) throws -> ModelDataSet? {
        let parameters = self.parametersForModelDataBySpot(spot)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        var modelDataSet: ModelDataSet? = try ModelDataSet(data: data)
        modelDataSet?.spot = spot
        return modelDataSet
    }

    open class func getModelDataBySpot(_ spot: Spot, completion: @escaping ModelDataSetCompletion) {
        let parameters = self.parametersForModelDataBySpot(spot)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    var modelDataSet = try ModelDataSet(data: data)
                    modelDataSet.spot = spot
                    return completion(.success(modelDataSet))
                } catch  {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Model Data Set by Spot ID
    class func parametersForModelDataBySpotID(_ spotID: Int) -> WFParameters {
        var parameters = WFParameters()
        parameters.append(self.spotIDDictionary(spotID))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        return parameters
    }

    open class func getModelDataBySpotID(_ spotID: Int) throws -> ModelDataSet? {
        let parameters = self.parametersForModelDataBySpotID(spotID)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        let modelDataSet = try ModelDataSet(data: data)
        return modelDataSet
    }

    open class func getModelDataBySpotID(_ spotID: Int, completion: @escaping ModelDataSetCompletion) {
        let parameters = self.parametersForModelDataBySpotID(spotID)
        let urlString: String = self.urlForService(getModelDataBySpotURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let modelDataSet = try ModelDataSet(data: data)
                    return completion(.success(modelDataSet))
                } catch  {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Model Data By Coordinate
    class func parametersForModelDataByCoordinate(_ coordinate: CLLocationCoordinate2D) -> WFParameters {
        var parameters = WFParameters()
        parameters += (self.coordinateArray(coordinate))
        parameters += (self.unitsArray)
        parameters.append(self.formatDictionary)
        return parameters
    }
    
    open class func getModelDataByCoordinate(_ coordinate: CLLocationCoordinate2D) throws -> ModelDataSet? {
        let parameters = self.parametersForModelDataByCoordinate(coordinate)
        let urlString: String = self.urlForService(getModelDataByLatLonURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        let modelDataSet = try ModelDataSet(data: data)
        return modelDataSet
    }

    open class func getModelDataByCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping ModelDataSetCompletion) {
        let parameters = self.parametersForModelDataByCoordinate(coordinate)
        let urlString: String = self.urlForService(getModelDataByLatLonURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let modelDataSet = try ModelDataSet(data: data)
                    return completion(.success(modelDataSet))
                } catch  {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }

            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // Spot Stats By Spot Id
    class func parametersForSpotStatsBySpotID(_ spotID: Int, years: Int?) -> WFParameters {
        var parameters = WFParameters()
        parameters.append(self.spotIDDictionary(spotID))
        //        parameters += (self.unitsArray)
        if let letYears = years {
            let yearsParam: WFParameters = [self.dictionaryWithParameter("years_back", value: "\(letYears)")]
            parameters += yearsParam
        }
        parameters += self.thresholdList
        parameters.append(self.formatDictionary)
        return parameters
    }
    /* TODO: Convert Stats to codable
    open class func getSpotStatsBySpotID(_ spotID: Int, years: Int?) throws -> SpotStats? {
        let parameters = self.parametersForSpotStatsBySpotID(spotID, years: years)
        let urlString: String = self.urlForService(getSpotStatsURL, andParameters: parameters)
        let dictionary = try self.dataFromURL(urlString)
        let spotStats = SpotStats(data: data)
        spotStats.spotID = spotID
        return spotStats
    }
    
    open class func getSpotStatsBySpotID(_ spotID: Int, years: Int?, completion: @escaping SpotStatsCompletion) {
        let parameters = self.parametersForSpotStatsBySpotID(spotID, years: years)
        let urlString: String = self.urlForService(getSpotStatsURL, andParameters: parameters)
        self.dictionaryFromURL(urlString) { (result) in
            switch result {
            case .success(let dictionary):
                let spotStats = SpotStats(spot_id: spotID, dictionary: dictionary)
                return completion(.success(spotStats))
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }*/
    
    // Graph For Spot Id
    class func parametersForGraphForSpotID(_ spotID: Int, unitWind: WFUnitWind?) -> WFParameters {
        var parameters = WFParameters()
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
        return parameters
    }

    open class func getGraphForSpotID(_ spotID: Int, unitWind: WFUnitWind?) throws -> Graph {
        let parameters = self.parametersForGraphForSpotID(spotID, unitWind: unitWind)
        let urlString: String = self.urlForService(getGraphURL, andParameters: parameters)
        let data = try self.dataFromURL(urlString)
        var graph = try Graph(data: data)
        graph.spotId = spotID
        return graph
    }

    open class func getGraphForSpotID(_ spotID: Int, unitWind: WFUnitWind?, completion: @escaping GraphCompletion) {
        let parameters = self.parametersForGraphForSpotID(spotID, unitWind: unitWind)
        let urlString: String = self.urlForService(getGraphURL, andParameters: parameters)
        self.dataFromURL(urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    var graph = try Graph(data: data)
                    graph.spotId = spotID
                    return completion(.success(graph))
                } catch {
                    return completion(.error(error: WeatherFlowApiError.jSonError(error: error)))
                }
            case .error(let error):
                return completion(.error(error: error))
            }
        }
    }

    // MARK: - UrlParameters Helpers
    open class func urlForService(_ service: String, andParameters parameters: WFParameters) -> String {
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
                let parametersString = "&"+String(describing: name)+"="+String(describing: value)
                string += parametersString
            }
        }
        return string
    }
    
    class var unitsArray: WFParameters {
        let array: WFParameters = [self.unitWindDictionary, self.unitDistanceDictionary, self.unitTempDictionary]
        return array
    }
    
    class var searchArray: WFParameters {
        if self.includeVirtualWeatherStations {
            return [self.dictionaryWithParameter("spot_types", value: "1,100,101")]
        }
        else {
            return [self.dictionaryWithParameter("spot_types", value: "1")]
        }
    }
    
    class var thresholdList: WFParameters {
        return [self.dictionaryWithParameter("threshold_list", value: "5,10,15,20,25")]
    }
    

    class func coordinateArray(_ coordinate: CLLocationCoordinate2D) -> WFParameters {
        let lat: String = String(format: "%0.5f", coordinate.latitude)
        let lon: String = String(format: "%0.5f", coordinate.longitude)
        return [self.dictionaryWithParameter("lat", value: lat), self.dictionaryWithParameter("lon", value: lon)]
    }
    
    class func spotSetByListDictionaryWithValue(_ value: IndexSet) -> [AnyHashable: Any] {
        var string = String()
        for (_, value) in value.enumerated() {
            let spotId = String(format: "%lu", arguments: [UInt(value)])
            string += spotId
            string += ","
        }
        if string.count > 0 {
            string.remove(at: string.index(before: string.endIndex))
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
    /// URL Request and then convert to Dictionary (sync)
    class func dataFromURL(_ urlString: String) throws -> Data {
        self.postRequestSentNotification(urlString: urlString)
        guard let url: URL = URL(string: urlString) else {
            throw WeatherFlowApiError.urlError
        }
        let (data, _, error) = self.urlSession.synchronousDataTaskWithURL(url)
            
        if let result = data {
            return result
        } else {
            if let letError = error {
                throw WeatherFlowApiError.serverError(error: letError)
            }
            throw WeatherFlowApiError.unknown
        }
    }
    
    /// URL Request and then convert to Dictionary (sync)
    class func dataFromURL(_ urlString: String, completion: @escaping (WeatherFlowApiResult<Data>) -> Void) {
        guard let url: URL = URL(string: urlString)  else {
            return completion(WeatherFlowApiResult.error(error: WeatherFlowApiError.urlError))
        }

        let task = self.urlSession.dataTask(with: url) { (data, response, error) in
            if let result = data {
                return completion(.success(result))
            } else {
                if let letError = error {
                    return completion(.error(error: .serverError(error: letError)))
                }
                return completion(.error(error: .unknown))
            }
        }
        self.postRequestSentNotification(urlString: urlString)
        task.resume()
    }
    
    
    /// Post Request Sent Notification
    class func postRequestSentNotification(urlString: String) {
        let explode = urlString.explode("/")
        if explode.count > 5 {
            let requestString = explode[5]
            let explodeRequest = requestString.explode("?")
            if explodeRequest.count > 0 {
                let request = explodeRequest[0]
                NotificationCenter.default.post(name: WeatherFlowApiSwift.UpdateNotification.WeatherFlowRequestSent.name, object: nil, userInfo: ["request" : request])
            }
        }
    }
    
    class func responseDictionaryFromJSONData(_ data: Data) throws -> [String: Any] {
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] {
                return responseDictionary
            }
        } catch let error as NSError {
            throw WeatherFlowApiError.jSonError(error: error)
        }
        throw WeatherFlowApiError.jSonError(error: nil)
    }
}


extension URLSession {
    func synchronousDataTaskWithURL(_ url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = self.dataTask(with: url as URL, completionHandler: {
            data = $0
            response = $1
            error = $2 as Error?
            sem.signal()
        })
        
        task.resume()
        
        let result = sem.wait(timeout: DispatchTime.distantFuture)
        switch result {
        case .success:
            return (data, response, error)
        case .timedOut:
            let error = URLSessionError(kind: URLSessionError.ErrorKind.timeout)
            return (data, response, error)
            
        }
    }
}

extension String {
    /**
     Returns an array of strings, each of which is a substring of self formed by splitting it on separator.
     - parameter separator: Character used to split the string
     - returns: Array of substrings
     */
    func explode (_ separator: Character) -> [String] {
        return self.split { $0 == separator }.map { String($0) }
    }
}

struct URLSessionError: Error {
    enum ErrorKind {
        case timeout
    }
    let kind: ErrorKind
    var localizedDescription: String {
        switch self.kind {
        case .timeout:
            return "Timeout Occured"
        }
    }
}

internal class BoolConverter {
    static func convert(_ value: Any?) -> Bool? {
        if let bool = value as? Bool {
            return bool
        }
        if let string = value as? String {
            return string.toBool()
        }
        return nil
    }
}

internal extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
