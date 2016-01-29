//
//  SpotStats.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 28/01/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//


public class SpotStats {

    public private (set) var spot_id: Int!
    public private (set) var name: String?
    public private (set) var status: Status?
    public private (set) var start_month: String?
    public private (set) var year_stat: YearStat?
    
    public init?(dictionary: [String : AnyObject]) {
        if let spot_id = dictionary["spot_id"] as? Int {
            self.spot_id = spot_id
        } else {
            return nil
        }
        self.name = (dictionary["name"] as? String)
        self.start_month = (dictionary["start_month"] as? String)
        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
            self.status = Status(dictionary: statusDictionary)
        }

        if let yearStat = dictionary["year_stat"] as? [String: AnyObject] {
            self.year_stat = YearStat(dictionary: yearStat)
        }
    }

}

public enum YearStatMonth: Int {
    case Jan
    case Feb
    case Mar
    case Apr
    case May
    case Jun
    case Jul
    case Aug
    case Sep
    case Oct
    case Nov
    case Dec
}

public enum YearStatDirection: Int {
    case N
    case NNE
    case NE
    case ENE
    case E
    case ESE
    case SE
    case SSE
    case S
    case SSW
    case SW
    case WSW
    case W
    case WNW
    case NW
    case NNW
}

public class YearStat {
    public private (set) var year: Int!
    
    public private (set) var avg_t0: [YearStatMonth: Int]?
    public private (set) var avg_t5: [YearStatMonth: Int]?
    public private (set) var avg_t10: [YearStatMonth: Int]?
    public private (set) var avg_t15: [YearStatMonth: Int]?
    public private (set) var avg_t20: [YearStatMonth: Int]?
    public private (set) var avg_t25: [YearStatMonth: Int]?

    public private (set) var gust_t0: [YearStatMonth: Int]?
    public private (set) var gust_t5: [YearStatMonth: Int]?
    public private (set) var gust_t10: [YearStatMonth: Int]?
    public private (set) var gust_t15: [YearStatMonth: Int]?
    public private (set) var gust_t20: [YearStatMonth: Int]?
    public private (set) var gust_t25: [YearStatMonth: Int]?

    public private (set) var dir_avg_t0: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_avg_t5: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_avg_t10: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_avg_t15: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_avg_t20: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_avg_t25: [YearStatMonth: [YearStatDirection: Int]]?

    public private (set) var dir_gust_t0: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_gust_t5: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_gust_t10: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_gust_t15: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_gust_t20: [YearStatMonth: [YearStatDirection: Int]]?
    public private (set) var dir_gust_t25: [YearStatMonth: [YearStatDirection: Int]]?
    

    public init?(dictionary: [String : AnyObject]) {
        if let year = dictionary["year"] as? Int {
            self.year = year
        } else {
            return nil
        }
        if let avg_array = dictionary["avg_t0"] as? [Int] {
            self.avg_t0 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }
        if let avg_array = dictionary["avg_t5"] as? [Int] {
            self.avg_t5 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }
        if let avg_array = dictionary["avg_t10"] as? [Int] {
            self.avg_t10 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }
        if let avg_array = dictionary["avg_t15"] as? [Int] {
            self.avg_t15 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }
        if let avg_array = dictionary["avg_t20"] as? [Int] {
            self.avg_t20 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }
        if let avg_array = dictionary["avg_t25"] as? [Int] {
            self.avg_t25 = YearStat.convertIntArrayToMonthDictionary(avg_array)
        }

        if let gust_array = dictionary["gust_t0"] as? [Int] {
            self.gust_t0 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t5"] as? [Int] {
            self.gust_t5 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t10"] as? [Int] {
            self.gust_t10 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t15"] as? [Int] {
            self.gust_t15 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t20"] as? [Int] {
            self.gust_t20 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t25"] as? [Int] {
            self.gust_t25 = YearStat.convertIntArrayToMonthDictionary(gust_array)
        }

        if let dir_avg_array = dictionary["dir_avg_t0"] as? [[Int]] {
            self.dir_avg_t0 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        if let dir_avg_array = dictionary["dir_avg_t5"] as? [[Int]] {
            self.dir_avg_t5 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        if let dir_avg_array = dictionary["dir_avg_t10"] as? [[Int]] {
            self.dir_avg_t10 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        if let dir_avg_array = dictionary["dir_avg_t15"] as? [[Int]] {
            self.dir_avg_t15 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        if let dir_avg_array = dictionary["dir_avg_t20"] as? [[Int]] {
            self.dir_avg_t20 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        if let dir_avg_array = dictionary["dir_avg_t25"] as? [[Int]] {
            self.dir_avg_t25 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_avg_array)
        }
        
        if let dir_gust_array = dictionary["dir_gust_t0"] as? [[Int]] {
            self.dir_gust_t0 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t5"] as? [[Int]] {
            self.dir_gust_t5 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t10"] as? [[Int]] {
            self.dir_gust_t10 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t15"] as? [[Int]] {
            self.dir_gust_t15 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t20"] as? [[Int]] {
            self.dir_gust_t20 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t25"] as? [[Int]] {
            self.dir_gust_t25 = YearStat.convertDirIntArrayToMonthDirectionDictionary(dir_gust_array)
        }
    }
    
    class func convertIntArrayToMonthDictionary(intArray: [Int]) -> [YearStatMonth: Int] {
        var monthDic = [YearStatMonth: Int]()
        for (index, numOfDays) in intArray.enumerate() {
            if let month = YearStatMonth(rawValue: index) {
                monthDic[month] = numOfDays
            }
        }
        return monthDic
    }

    class func convertDirIntArrayToMonthDirectionDictionary(intArray: [[Int]]) -> [YearStatMonth: [YearStatDirection: Int]] {
        var monthDic = [YearStatMonth: [YearStatDirection: Int]]()
        for (monthIndex, directionArray) in intArray.enumerate() {
            if let month = YearStatMonth(rawValue: monthIndex) {
                var directionDic = [YearStatDirection: Int]()
                for (directionIndex, num) in directionArray.enumerate() {
                    if let direction = YearStatDirection(rawValue: directionIndex) {
                        directionDic[direction] = num
                    }
                }
                monthDic[month] = directionDic
            }
        }
        return monthDic
    }
}
