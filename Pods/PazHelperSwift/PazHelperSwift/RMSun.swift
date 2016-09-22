//
//  RMSun.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 03/11/2014.
//  Copyright (c) 2014 paz-labs. All rights reserved.
//

import Foundation

let RMSunZenithOfficial = 90.83
let RMSunZenithCivil = 96
let RMSunZenithNautical = 102
let RMSunZenithAstronomical = 108

func adjustToMax(_ input: Double, max: Double) ->  Double {
    var L = input
    
    while (L < 0.0)
    {
        L += max;
    }
    while(L > max)
    {
        L -= max;
    }
    
    return L;
}

func RMSunCalculate (_ sunrise: Bool, latitude: Double, longitude: Double, date: Date, zenith: Double) -> Date? {
    // Split the date into components
    if let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) {
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        let unitFlags: NSCalendar.Unit = ([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day])
        var components = calendar.components(unitFlags, from: date as Date)
        
        // Get the day of the year
        let dayOfYear = calendar.ordinality(of: NSCalendar.Unit.day, in: NSCalendar.Unit.year, for: date as Date)
        
        // Convert the longitude to hour value and calculate an approximate time
        let lngHour = longitude / 15.0;
        let t = Double(dayOfYear) + (((sunrise ? 6.0 : 18.0) - lngHour) / 24.0)
        
        // Calculate the Sun's mean anomaly
        let M = (0.9856 * t) - 3.289;
        
        // Calculate the Sun's true longitude
        var L = M + (1.916 * sin(PazUnitAngle.DEGREES_TO_RADIANS(M))) + (0.020 * sin(2 * PazUnitAngle.DEGREES_TO_RADIANS(M))) + 282.634
        L = adjustToMax(L, max: 360.0);
        
        // Calculate the Sun's right ascension
        var sunRA = PazUnitAngle.RADIANS_TO_DEGREES(atan(0.91764 * tan(PazUnitAngle.DEGREES_TO_RADIANS(L))));
        sunRA = adjustToMax(sunRA, max: 360.0);
        
        // Right ascension needs to be in the same quadrant as L
        let lQuadrant = floor(L / 90) * 90;
        let raQuadrant = floor(sunRA / 90) * 90;
        sunRA = sunRA + (lQuadrant - raQuadrant);
        
        // Convert right ascension to hours
        sunRA = sunRA / 15;
        
        // Calculate the Sun's declination
        let sinDec = 0.39782 * sin(PazUnitAngle.DEGREES_TO_RADIANS(L));
        let cosDec = cos(asin(sinDec));
        
        // Calculate the Sun's local hour angle
        let cosH = (cos(PazUnitAngle.DEGREES_TO_RADIANS(zenith)) - (sinDec * sin(PazUnitAngle.DEGREES_TO_RADIANS(latitude)))) / (cosDec * cos(PazUnitAngle.DEGREES_TO_RADIANS(latitude)));
        let cosHCheck = sunrise ? cosH > 1 : cosH < -1
        if(cosHCheck)
        {
            // The sun never rises here on this date
            return nil;
        }
        
        // Finish calculating H and convert into hours
        var H = sunrise ? 360 - PazUnitAngle.RADIANS_TO_DEGREES(acos(cosH)) : PazUnitAngle.RADIANS_TO_DEGREES(acos(cosH))
        H = H / 15
        
        // Calculate local mean time of rising / setting
        let T = H + sunRA - (0.06571 * t) - 6.622
        
        // Adjust back to UTC
        var UT = (T - lngHour)
        UT = adjustToMax(UT, max: 24)
        
        // Create a date from the components and a UT calendar
        let hour = floor(UT)
        let minute = floor((UT - hour) * 60.0)
        let second = (((UT - hour) * 60.0) - minute) * 60.0
        
        components.hour = Int(hour)
        components.minute = Int(minute)
        components.second = Int(second)
        
        let theDate = calendar.date(from: components)
        
        return theDate;
    }
    return nil
}

func RMSunCalculateSunrise(_ latitude: Double, longitude: Double, date: Date, zenith: Double) -> Date? {
    return RMSunCalculate(true, latitude: latitude, longitude: longitude, date: date, zenith: zenith)
}

func RMSunCalculateSunset(_ latitude: Double, longitude: Double, date: Date, zenith: Double) -> Date? {
    return RMSunCalculate(false, latitude: latitude, longitude: longitude, date: date, zenith: zenith)
}
