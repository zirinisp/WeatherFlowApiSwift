//
//  PazLocationManager.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 26/10/2014.
//  Copyright (c) 2014 paz-labs. All rights reserved.
//

import UIKit
import MapKit

/*  One siglenton class to manage location changes.
Then everytime we need to access it, create an instance. Instance will have blocks to update everything
*/

extension CLLocationCoordinate2D: Equatable {}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
}


public func Distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
    let lat1 = from.latitude;
    let lon1 = from.longitude;
    let lat2 = to.latitude;
    let lon2 = to.longitude;
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    let lat1rad = DegreesToRadians(lat1);
    let lat2rad = DegreesToRadians(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    let distance = acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DegreesToRadians(lon2) - DegreesToRadians(lon1))) * 6378.1;
    return distance;
}

public extension CLLocationCoordinate2D {
    // In meteres
    func distance(to:CLLocationCoordinate2D) -> PazUnit<PazUnitDistance> {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let meters = from.distance(from: to)
        let distance = PazUnit<PazUnitDistance>(meters, unit: PazUnitDistance.Meters)
        return distance
    }
}

/// Helper to manager hours in a given range. End Hour is excluded. StartHour should not Be equal to EndHour
@available(iOS 8.0, *)
public class PazHourRange {
    class func hourFrom(_ int: Int) -> Int {
        return int % 24
    }
    
    class func nextHour(_ hour: Int) -> Int {
        let nextHour = PazHourRange.hourFrom(hour + 1)
        return nextHour
    }
    
    class func previousHour(_ hour: Int) -> Int {
        let previousHour = PazHourRange.hourFrom(hour - 1)
        return previousHour
    }
    
    init(startHour: Int, endHour: Int) {
        var adjustedEndHour = endHour
        if startHour == endHour {
            adjustedEndHour = endHour - 1
        }
        self.startHour = PazHourRange.hourFrom(startHour)
        self.endHour = PazHourRange.hourFrom(adjustedEndHour)
        self.referenceDate = Date()
    }
    /// :WARING: Only hour part of the date is taken into account and it is rounded
    convenience init(startDate: Date, endDate: Date) {
        self.init(startHour: startDate.roundHour, endHour: endDate.roundHour)
    }
    
    private (set) public var startHour: Int
    private (set) public var endHour: Int
    
    public var referenceDate: Date {
        didSet {
            self._hourDateArray = nil
        }
    }
    
    public lazy var invertedRange: PazHourRange = {
        return PazHourRange(startHour: self.endHour, endHour: self.startHour)
        }()
    
    public lazy var hourArray: Array<Int> = {
        var array = Array<Int>()
        var hour = self.startHour
        while hour != self.endHour {
            array.append(hour)
            hour = PazHourRange.nextHour(hour)
        }
        return array
        }()
    
    private var _hourDateArray: Array<Date>?
    public var hourDateArray: Array<Date> {
        if let array = self._hourDateArray {
            return array
        }
        let array = self.hourDateArrayFor(self.referenceDate) ?? [Date]()
        //self._hourDateArray = array
        return array
    }
    
    public func hourDateArrayFor(_ date: Date) -> [Date]? {
        // Create start hour from reference date
        var components = PazLocationManager.sharedInstance.calendar.components([.year, .month, .day, .hour], from: date as Date)
        components.calendar = PazLocationManager.sharedInstance.calendar as Calendar
        components.hour = self.startHour
        var array = Array<Date>()
        if let startDate = components.date {
            for i in 0..<self.count {
                let date = startDate.addingTimeInterval(i * 60 * 60)
                array.append(date)
            }
        }
        if array.count != self.count || array[array.count - 1].hours != self.endHour - 1 {
            print("Problem in PazHourRange hourDateArray")
        }
        return array
        
    }
    
    public var count: Int {
        return self.hourArray.count
    }
    
    func isInRange(_ hour: Int) -> Bool {
        return self.hourArray.contains(PazHourRange.hourFrom(hour))
    }
    func isInRange(_ date: Date) -> Bool {
        return self.hourArray.contains(PazHourRange.hourFrom(date.hours))
    }
}

@available(iOS 8.0, *)
public func ==(lhs: PazHourRange, rhs: PazHourRange) -> Bool {
    return lhs.startHour == rhs.startHour && lhs.endHour == rhs.endHour
}

@available(iOS 8.0, *)
public func !=(lhs: PazHourRange, rhs: PazHourRange) -> Bool {
    return !(lhs == rhs)
}

@available(iOS 8.0, *)
public class PazLocationManager: NSObject, CLLocationManagerDelegate {
    
    public static var disabled = false
    
    public class func UpdateNotificationLocation() -> String { return "kPazLocationManagerLocationUpdateNotification" }
    public class func UpdateNotificationCache() -> String { return "kLocationManagerCacheUpdateNotification" }
    
    /* Private variables */
    private var locationStatus : NSString = "Calibrating"// to pass in handler
    @available(iOS 8.0, *)
    lazy private var locationManager: CLLocationManager = {
        let initialLocationManager = CLLocationManager()
        if PazLocationManager.disabled {
            return initialLocationManager
        }
        initialLocationManager.delegate = self
        initialLocationManager.desiredAccuracy = self.desiredAccuracy
        let code = CLLocationManager.authorizationStatus()
        if code == CLAuthorizationStatus.notDetermined {
            if let description = Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") as? String {
                initialLocationManager.requestAlwaysAuthorization()
            } else if let description = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String {
                initialLocationManager.requestWhenInUseAuthorization()
            } else {
                print("!!!WARNING:!!!\nInfo.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
        return initialLocationManager
        }()
    
    private var verboseMessage = "Calibrating"
    
    
    private let verboseMessageDictionary = [CLAuthorizationStatus.notDetermined:"You have not yet made a choice with regards to this application.",
        CLAuthorizationStatus.restricted:"This application is not authorized to use location services. Due to active restrictions on location services, the user cannot change this status, and may not have personally denied authorization.",
        CLAuthorizationStatus.denied:"You have explicitly denied authorization for this application, or location services are disabled in Settings.",
        CLAuthorizationStatus.authorizedAlways:"App is Authorized to use location services.",
        CLAuthorizationStatus.authorizedWhenInUse:"You have granted authorization to use your location only when the app is visible to you."]
    
    public var desiredAccuracy : CLLocationAccuracy {
        didSet {
            self.locationManager.desiredAccuracy = self.desiredAccuracy
        }
    }
    
    public var location : CLLocation?
    public var coordinates : CLLocationCoordinate2D {
        if let location = self.location  {
            return location.coordinate
        } else {
            return self.lastKnownCoordinates
        }
    }
    
    public var latitude:Double {
        return self.coordinates.latitude
    }
    public var longitude:Double {
        return self.coordinates.longitude
    }
    
    var latitudeAsString:String = ""
    var longitudeAsString:String = ""
    
    var lastKnownLocation : CLLocation? {
        didSet {
            if self.lastKnownLocation != nil {
                self.updateCacheIfNeeded()
            }
        }
    }
    var lastKnownCoordinates : CLLocationCoordinate2D {
        if let location = self.lastKnownLocation  {
            return location.coordinate
        } else {
            return CLLocationCoordinate2DMake(0.0, 0.0)
        }
    }
    var lastKnownLatitude:Double {
        return self.lastKnownCoordinates.latitude
    }
    var lastKnownLongitude:Double {
        return self.lastKnownCoordinates.longitude
    }
    
    var lastKnownLatitudeAsString:String {
        return self.lastKnownCoordinates.latitude.description
        
    }
    var lastKnownLongitudeAsString:String {
        return self.lastKnownCoordinates.longitude.description
    }
    
    
    var keepLastKnownLocation:Bool = true
    var hasLastKnownLocation:Bool = true
    
    public var autoUpdate:Bool = false
    
    var showVerboseMessage = false
    
    public var isRunning = false
    
    
    public class var sharedInstance : PazLocationManager {
        struct Static {
            static let instance : PazLocationManager = PazLocationManager()
        }
        return Static.instance
    }
    
    public class func startUpdatingLocation(desiredAccuracy: CLLocationAccuracy) {
        self.sharedInstance.desiredAccuracy = desiredAccuracy
        self.sharedInstance.autoUpdate = true
        self.sharedInstance.startUpdatingLocation()
    }
    
    public override init(){
        desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        if(!autoUpdate){
            autoUpdate = !CLLocationManager.significantLocationChangeMonitoringAvailable()
        }
        _ = self.locationManager
    }
    
    public init(desiredAccuracy: CLLocationAccuracy) {
        self.desiredAccuracy = desiredAccuracy
        super.init()
        if(!autoUpdate){
            autoUpdate = !CLLocationManager.significantLocationChangeMonitoringAvailable()
        }
        self.startUpdatingLocation()
    }
    
    private func resetLatLon(){
        self.location = nil
    }
    
    private func resetLastKnownLatLon(){
        
        hasLastKnownLocation = false
        
        self.lastKnownLocation = nil
    }
    
    public func startUpdatingLocation(){
        self.startLocationManger()
    }
    
    public func stopUpdatingLocation(){
        
        if(autoUpdate){
            locationManager.stopUpdatingLocation()
        }else{
            
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        
        
        resetLatLon()
        if(!keepLastKnownLocation){
            resetLastKnownLatLon()
        }
    }
    
    private func startLocationManger(){
        
        if(autoUpdate){
            
            locationManager.startUpdatingLocation()
        }else{
            
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        isRunning = true
        
    }
    
    
    private func stopLocationManger(){
        
        if(autoUpdate){
            
            locationManager.stopUpdatingLocation()
        }else{
            
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        
        isRunning = false
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //stopLocationManger()
        
        //resetLatLon()
        
        if(!keepLastKnownLocation){
            
            resetLastKnownLatLon()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let arrayOfLocation = locations as NSArray
        if let currentLocation = arrayOfLocation.lastObject as? CLLocation {
            self.location = currentLocation
            self.lastKnownLocation = currentLocation
            hasLastKnownLocation = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PazLocationManager.UpdateNotificationLocation()), object: self)
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var hasAuthorised = false
            let verboseKey = status
            switch status {
            case CLAuthorizationStatus.restricted:
                locationStatus = "Restricted Access"
            case CLAuthorizationStatus.denied:
                locationStatus = "Denied access"
            case CLAuthorizationStatus.notDetermined:
                locationStatus = "Not determined"
            default:
                locationStatus = "Allowed access"
                hasAuthorised = true
            }
            
            verboseMessage = verboseMessageDictionary[verboseKey]!
            
            if (hasAuthorised == true) {
                startLocationManger()
            }else{
                resetLatLon()
            }
    }
    // MARK: - Sunset/Sunrise
    /*
    The following functions help find the sunset and sunrise for any given location
    */
    public class func UpdateNotificationSunsetSunrise() -> String {
        return "PazLocationManagerUpdateNotificationSunsetSunrise"
    }
    /*
    func defaultSunDateFor(sunrise: Bool, date: Date) -> Date? {
    var reply: Date? = nil
    if let gregorian = NSCalendar(calendarIdentifier:NSGregorianCalendar) {
    var dateComponents = gregorian.components((NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.DayCalendarUnit |
    NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit), fromDate:date)
    dateComponents.hour = sunrise ? 7 : 19
    dateComponents.minute = sunrise ? 59 : 59
    reply = gregorian.dateFromComponents(dateComponents)
    }
    return reply
    }*/
    public func sunriseFor(_ date: Date) -> Date? {
        let coordinate = self.cachedLocation.coordinate
        return self.sunriseFor(date, coordinates:coordinate)
    }
    public func sunriseFor(_ date: Date, coordinates: CLLocationCoordinate2D) -> Date? {
        //var sunrise : Date? = nil
        if (!CLLocationCoordinate2DIsValid(coordinates) || coordinates.latitude == 0 || coordinates.longitude == 0) {
            return nil//self.defaultSunDateFor(true, date: date)
        } else {
            return RMSunCalculateSunrise(coordinates.latitude, longitude: coordinates.longitude, date: date, zenith: RMSunZenithOfficial);
        }
    }
    
    public func sunsetFor(_ date: Date) -> Date? {
        let coordinate = self.cachedLocation.coordinate
        return self.sunsetFor(date, coordinates:coordinate)
    }
    
    public func sunsetFor(_ date: Date, coordinates: CLLocationCoordinate2D) -> Date? {
        if (!CLLocationCoordinate2DIsValid(coordinates) || coordinates.latitude == 0 || coordinates.longitude == 0) {
            return nil //self.defaultSunDateFor(false, date: date)
        } else {
            return RMSunCalculateSunset(coordinates.latitude, longitude: coordinates.longitude, date: date, zenith: RMSunZenithOfficial);
        }
    }
    
    public func dayHourRangeFor(_ date: Date) -> PazHourRange {
        if let sunrise = self.sunriseFor(date) {
            if let sunset = self.sunsetFor(date) {
                return PazHourRange(startDate: sunrise, endDate: sunset)
            }
        }
        return PazLocationManager.lastDayHours()
    }
    
    public func dayHourRangeFor(_ date: Date, coordinates: CLLocationCoordinate2D) -> PazHourRange {
        if let sunrise = self.sunriseFor(date, coordinates: coordinates) {
            if let sunset = self.sunsetFor(date, coordinates: coordinates) {
                return PazHourRange(startDate: sunrise, endDate: sunset)
            }
        }
        return PazLocationManager.lastDayHours()
    }
    
    public func isDay(_ date: Date) -> Bool {
        let interval = abs(date.timeIntervalSince(self.cachedDate as Date))
        let tenDayInterval = 60*60*24*7*10
        if interval < tenDayInterval {
            return self.isDayAtHour(date.hours)
        }
        return self.isDay(date, coordinate: self.coordinates)
    }
    public func isNight(_ date: Date) -> Bool {
        return !self.isDay(date)
    }
    public func isDay(_ date: Date, coordinate: CLLocationCoordinate2D) -> Bool {
        if let sunset = self.sunsetFor(date, coordinates:coordinate) {
            if let sunrise = self.sunriseFor(date, coordinates:coordinate) {
                let riseThenSet = sunset.isLaterThan(sunrise)
                if (riseThenSet) {
                    let laterThanSunrise = date.isLaterThan(sunrise)
                    let earlierThanSunset = date.isEarlierThan(sunset)
                    return (laterThanSunrise && earlierThanSunset);
                } else {
                    let earlierThanSunset = date.isEarlierThan(sunset)
                    let laterThanSunrise = date.isLaterThan(sunrise)
                    return (earlierThanSunset || laterThanSunrise);
                }
            }
        }
        return true
    }
    
    var sameDay: Bool {
        return self.sunsetHour > self.sunriseHour
    }
    
    public func isDayAtHour(_ hour: Int) -> Bool {
        return self.dayHours.isInRange(hour)
    }
    
    public func isNight(_ date: Date, coordinate: CLLocationCoordinate2D) -> Bool {
        return !self.isDay(date, coordinate: coordinate)
    }
    // MARK: Cached Results
    private var _cachedDate : Date?
    var cachedDate: Date {
        if _cachedDate == nil {
            _cachedDate = Date()
        }
        return _cachedDate!
    }
    private var _cachedLocation : CLLocation?
    var cachedLocation : CLLocation {
        if _cachedLocation == nil {
            if let location = self.lastKnownLocation {
                _cachedLocation = location
                self.updateDayHoursIfNeeded()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: PazLocationManager.UpdateNotificationCache()), object:self)
                return location
            }
            return CLLocation(latitude: 0.0, longitude: 0.0)
        }
        return self._cachedLocation!
    }
    private var _calendar : NSCalendar?
    public var calendar : NSCalendar {
        if _calendar == nil {
            _calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
            _calendar?.timeZone = NSTimeZone.local
        }
        return _calendar!
    }
    
    private var _dayHours: PazHourRange?
    public var dayHours: PazHourRange {
        if self._dayHours == nil {
            self.updateDayHoursIfNeeded()
        }
        return self._dayHours!
    }
    public var nightHours: PazHourRange {
        return self.dayHours.invertedRange
    }
    
    public var sunriseHour: Int {
        return self.dayHours.startHour
    }
    
    public var sunsetHour: Int {
        return self.dayHours.endHour
    }
    func resetCache() {
        _calendar = nil;
        _cachedLocation = nil;
        _cachedDate = nil;
        self.updateDayHoursIfNeeded()
    }
    
    private class func lastDayHours() -> PazHourRange {
        var startHour = 8
        var endHour = 21
        if let hour = UserDefaults.standard.object(forKey: "kLastDayHoursStartKey") as? Int {
            startHour = hour
        }
        if let hour = UserDefaults.standard.object(forKey: "kLastDayHoursEndKey") as? Int {
            endHour = hour
        }
        return PazHourRange(startHour: startHour, endHour: endHour)
    }
    
    private class func setLastDayHours(_ hourRange: PazHourRange) {
        UserDefaults.standard.set(hourRange.startHour, forKey:"kLastDayHoursStartKey")
        UserDefaults.standard.set(hourRange.endHour, forKey: "kLastDayHoursEndKey")
        UserDefaults.standard.synchronize()
    }
    
    func updateDayHoursIfNeeded() {
        let newDayHours = self.dayHourRangeFor(self.cachedDate)
        if let oldHours = self._dayHours {
            if newDayHours == oldHours {
                return
            }
        }
        PazLocationManager.setLastDayHours(newDayHours)
        self._dayHours = newDayHours
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PazLocationManager.UpdateNotificationSunsetSunrise()), object: self)
    }
    
    func updateCacheIfNeeded() {
        if let lastKnownLocation = self.lastKnownLocation {
            if (lastKnownLocation.distance(from: self.cachedLocation) < 10000 && self.cachedDate.timeIntervalSinceNow < 60*60*24) {
                return
            }
        }
        self.resetCache()
        // Trigger update
        let _ = self.cachedLocation
    }
    
    // Used for testing to update location
    public func forceUpdateLocation(_ location: CLLocation) {
        self.locationManager(self.locationManager, didUpdateLocations: [location])
    }
}
