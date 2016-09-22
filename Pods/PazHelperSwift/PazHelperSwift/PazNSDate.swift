//
//  File.swift
//  ExSwift
//
//  Created by Piergiuseppe Longo on 23/11/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

@available(iOS 8.0, *)
public extension Date {
    
    // MARK:  Date Manipulation
    
    /**
    Returns a new Date object representing the date calculated by adding the amount specified to self date
    
    - parameter seconds: number of seconds to add
    - parameter minutes: number of minutes to add
    - parameter hours: number of hours to add
    - parameter days: number of days to add
    - parameter weeks: number of weeks to add
    - parameter months: number of months to add
    - parameter years: number of years to add
    - returns: the Date computed
    */
    public func add(seconds:Int=0, minutes:Int = 0, hours:Int = 0, days:Int = 0, weeks:Int = 0, months:Int = 0, years:Int = 0) -> Date? {
        let calendar = Calendar.current
        var date = calendar.date(byAdding: Calendar.Component.second, value: seconds, to: self)
        date = calendar.date(byAdding: Calendar.Component.minute, value: minutes, to: self)
        date = calendar.date(byAdding: Calendar.Component.hour, value: hours, to: self)
        date = calendar.date(byAdding: Calendar.Component.weekOfMonth, value: weeks, to: self)
        date = calendar.date(byAdding: Calendar.Component.month, value: months, to: self)
        date = calendar.date(byAdding: Calendar.Component.year, value: years, to: self)
        return date
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of seconds to self date
    
    - parameter seconds: number of seconds to add
    - returns: the Date computed
    */
    public func addSeconds (_ seconds:Int) -> Date? {
        return add(seconds: seconds)
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of minutes to self date
    
    - parameter minutes: number of minutes to add
    - returns: the Date computed
    */
    public func addMinutes (_ minute:Int) -> Date? {
        return add(minutes: minute)
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of hours to self date
    
    - parameter hours: number of hours to add
    - returns: the Date computed
    */
    public func addHours(_ hours:Int) -> Date? {
        return add(hours: hours)
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of days to self date
    
    - parameter days: number of days to add
    - returns: the Date computed
    */
    public func addDays(_ days:Int) -> Date? {
        return add(days: days)
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of weeks to self date
    
    - parameter weeks: number of weeks to add
    - returns: the Date computed
    */
    public func addWeeks(_ weeks:Int) -> Date? {
        return add(weeks: weeks)
    }
    
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of months to self date
    
    - parameter months: number of months to add
    - returns: the Date computed
    */
    
    public func addMonths(_ months:Int) -> Date? {
        return add(months: months)
    }
    
    /**
    Returns a new Date object representing the date calculated by adding an amount of years to self date
    
    - parameter years: number of year to add
    - returns: the Date computed
    */
    public func addYears(_ years:Int) -> Date? {
        return add(years:years)
    }
    
    // MARK:  Date comparison
    
    /**
    Checks if self is after input Date
    
    - parameter date: Date to compare
    - returns: True if self is after the input Date, false otherwise
    */
    public func isAfter(_ date: Date) -> Bool{
        return (self.compare(date as Date) == ComparisonResult.orderedDescending)
    }
    
    /**
    Checks if self is after input Date
    
    - parameter date: Date to compare
    - returns: True if self is after the input Date, false otherwise
    */
    func isLaterThan(_ date: Date) -> Bool {
        return !self.isEarlierThan(date)
    }
    
    /**
    Checks if self is before input Date
    
    - parameter date: Date to compare
    - returns: True if self is before the input Date, false otherwise
    */
    public func isBefore(_ date: Date) -> Bool{
        return (self.compare(date as Date) == ComparisonResult.orderedAscending)
    }
    
    /**
    Checks if self is before input Date
    
    - parameter date: Date to compare
    - returns: True if self is before the input Date, false otherwise
    */
    func isEarlierThan(_ date: Date) -> Bool {
        return !(self.compare(date as Date) == ComparisonResult.orderedDescending)
    }
    
    
    /**
    Checks if self is the same date ignoring everything after hour
    
    - parameter date: Date to compare
    - returns: True if self is the same ignoring everything after hour true, false otherwise
    */
    func isSameUpToHour(_ date: Date) -> Bool {
        return self.hours == date.hours && self.isSameUpToDay(date)
    }
    
    /**
    Checks if self is the same date ignoring everything after day
    
    - parameter date: Date to compare
    - returns: True if self is the same ignoring everything after day true, false otherwise
    */
    func isSameUpToDay(_ date: Date) -> Bool {
        return self.days == date.days && self.isSameUpToMonth(date)
    }
    
    /**
    Checks if self is the same date ignoring everything after month
    
    - parameter date: Date to compare
    - returns: True if self is the same ignoring everything after month true, false otherwise
    */
    func isSameUpToMonth(_ date: Date) -> Bool {
        return self.month == date.month && self.year == date.year
    }
    
    
    // MARK: Getter
    
    /**
    Date year
    */
    public var year : Int {
        
        get {
            return getComponent(.year)
        }
    }
    
    /**
    Date month
    */
    public var month : Int {
        
        get {
            return getComponent(.month)
        }
    }
    
    /**
    Date weekday
    */
    public var weekday : Int {
        
        get {
            return getComponent(.weekday)
        }
    }
    
    /**
    Date weekMonth
    */
    public var weekMonth : Int {
        
        get {
            return getComponent(.weekOfMonth)
        }
    }
    
    
    /**
    Date days
    */
    public var days : Int {
        
        get {
            return getComponent(.day)
        }
    }
    
    /**
    Date hours
    */
    public var hours : Int {
        
        get {
            return getComponent(.hour)
        }
    }
    
    /**
    Date hours rounded to closest hour
    */
    public var roundHour : Int {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = NSTimeZone.local
        let comps = calendar.dateComponents(([Calendar.Component.hour, Calendar.Component.minute]), from:self as Date)
        let hour = comps.minute! < 30 ? comps.hour : comps.hour! + 1
        return hour!
    }
    
    /**
    Date rounded to closest hour
    */
    public var roundHourDate : Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = NSTimeZone.local
        var comps = calendar.dateComponents(([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour]), from:self)
        let roundHour = self.roundHour
        comps.hour = roundHour
        if roundHour == 0 && self.hours == 23 {
            comps.day! += 1
        }
        if let date = comps.date {
            return date
        }
        return self
    }
    
    /**
    Date minuts
    */
    public var minutes : Int {
        
        get {
            return getComponent(.minute)
        }
    }
    
    /**
    Date seconds
    */
    public var seconds : Int {
        
        get {
            return getComponent(.second)
        }
    }
    
    /**
    Returns the value of the Date component
    
    - parameter component: CalendarUnit
    - returns: the value of the component
    */
    
    public func getComponent (_ component : Calendar.Component) -> Int {
        let calendar = Calendar.current
        let value = calendar.component(component, from: self)
        return value
    }
    
    ///Returns the days difference from the dates given
    public static func daysBetweenDate(_ fromDate: Date, toDate: Date) -> Int {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = NSTimeZone.local
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        return components.day ?? 0
    }
    
    public func daysTillDate(_ toDate: Date) -> Int {
        return Date.daysBetweenDate(self, toDate:toDate)
    }
}

// MARK: Comparable functions
/* Swift 3 includes them
public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs as Date) == ComparisonResult.orderedSame
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs as Date) == ComparisonResult.orderedAscending
}

public func >(lhs: Date, rhs: Date) -> Bool {
    return !(lhs <= rhs)
}

public func <=(lhs: Date, rhs: Date) -> Bool {
    return lhs < rhs || lhs == rhs
}

public func >=(lhs: Date, rhs: Date) -> Bool {
    return lhs > rhs || lhs == rhs
}

extension Date: Comparable {
}
*/
