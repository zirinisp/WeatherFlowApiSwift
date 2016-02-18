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
    public private (set) var year_stats: [YearStat]?
    
    public init?(spot_id: Int, dictionary: [String : AnyObject]) {
        self.spot_id = spot_id
        self.name = (dictionary["name"] as? String)
        self.start_month = (dictionary["start_month"] as? String)
        if let statusDictionary = dictionary["status"] as? [String: AnyObject] {
            self.status = Status(dictionary: statusDictionary)
        }
        var year_stats = [YearStat]()
        if let statistics = dictionary["year_stat"] as? [[String: AnyObject]] {
            for yearStatDictionary in statistics {
                if let yearStat = YearStat(dictionary: yearStatDictionary) {
                    year_stats.append(yearStat)
                }
            }
        }
        self.year_stats = year_stats
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
    
    /// Initialize with direction in degrees
    init?(direction: Int) {
        let offset = YearStatDirection.divident / 2.0
        var correctedDirection: Double = Double(direction) + offset
        while correctedDirection < 0 {
            correctedDirection += 360.0
        }
        let position = correctedDirection / YearStatDirection.divident
        self.init(rawValue: Int(position))
    }
    
    static var divident: Double {
        return 360.0 / Double(YearStatDirection.count)
    }
    
    static let count: Int = {
        var max: Int = 0
        while let _ = YearStatDirection(rawValue: max) { max += 1 }
        return max
    }()
}

public class YearStat {
    public private (set) var year: String!
    
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
        if let year = dictionary["year"] as? String {
            self.year = year
        } else {
            return nil
        }
        
        if let avgString = dictionary["avg_t0"] as? String {
            self.avg_t0 = YearStat.convertStringToMonthDictionary(avgString)
        }
        if let avgString = dictionary["avg_t5"] as? String {
            self.avg_t5 = YearStat.convertStringToMonthDictionary(avgString)
        }
        if let avgString = dictionary["avg_t10"] as? String {
            self.avg_t10 = YearStat.convertStringToMonthDictionary(avgString)
        }
        if let avgString = dictionary["avg_t15"] as? String {
            self.avg_t15 = YearStat.convertStringToMonthDictionary(avgString)
        }
        if let avgString = dictionary["avg_t20"] as? String {
            self.avg_t20 = YearStat.convertStringToMonthDictionary(avgString)
        }
        if let avgString = dictionary["avg_t25"] as? String {
            self.avg_t25 = YearStat.convertStringToMonthDictionary(avgString)
        }

        if let gust_array = dictionary["gust_t0"] as? String {
            self.gust_t0 = YearStat.convertStringToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t5"] as? String {
            self.gust_t5 = YearStat.convertStringToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t10"] as? String {
            self.gust_t10 = YearStat.convertStringToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t15"] as? String {
            self.gust_t15 = YearStat.convertStringToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t20"] as? String {
            self.gust_t20 = YearStat.convertStringToMonthDictionary(gust_array)
        }
        if let gust_array = dictionary["gust_t25"] as? String {
            self.gust_t25 = YearStat.convertStringToMonthDictionary(gust_array)
        }

        if let dir_avgString = dictionary["dir_avg_t0"] as? String {
            self.dir_avg_t0 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        if let dir_avgString = dictionary["dir_avg_t5"] as? String {
            self.dir_avg_t5 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        if let dir_avgString = dictionary["dir_avg_t10"] as? String {
            self.dir_avg_t10 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        if let dir_avgString = dictionary["dir_avg_t15"] as? String {
            self.dir_avg_t15 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        if let dir_avgString = dictionary["dir_avg_t20"] as? String {
            self.dir_avg_t20 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        if let dir_avgString = dictionary["dir_avg_t25"] as? String {
            self.dir_avg_t25 = YearStat.convertStringToMonthDirectionDictionary(dir_avgString)
        }
        
        if let dir_gust_array = dictionary["dir_gust_t0"] as? String {
            self.dir_gust_t0 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t5"] as? String {
            self.dir_gust_t5 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t10"] as? String {
            self.dir_gust_t10 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t15"] as? String {
            self.dir_gust_t15 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t20"] as? String {
            self.dir_gust_t20 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
        if let dir_gust_array = dictionary["dir_gust_t25"] as? String {
            self.dir_gust_t25 = YearStat.convertStringToMonthDirectionDictionary(dir_gust_array)
        }
    }
    
    class func convertStringToMonthDictionary(stringArray: String) -> [YearStatMonth: Int]? {
        var monthDic = [YearStatMonth: Int]()
        var string: String = stringArray
        string = string.stringByReplacingOccurrencesOfString("[", withString: "")
        string = string.stringByReplacingOccurrencesOfString("]", withString: "")
        string = string.stringByReplacingOccurrencesOfString(" ", withString: "")

        let array = string.componentsSeparatedByString(",")
        for (index, numOfDays) in array.enumerate() {
            if let month = YearStatMonth(rawValue: index) {
                if let num = numOfDays.toUInt() {
                    monthDic[month] = Int(num)
                }
            }
        }
        return monthDic
    }

    class func convertStringToMonthDirectionDictionary(inputString: String) -> [YearStatMonth: [YearStatDirection: Int]]? {
        let yearStringArray = inputString.componentsSeparatedByString("],")

        var monthDic = [YearStatMonth: [YearStatDirection: Int]]()
        for (monthIndex, monthStringArray) in yearStringArray.enumerate() {
            if let month = YearStatMonth(rawValue: monthIndex) {
                var string: String = monthStringArray
                string = string.stringByReplacingOccurrencesOfString("[", withString: "")
                string = string.stringByReplacingOccurrencesOfString("]", withString: "")
                string = string.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                let directionArray = string.componentsSeparatedByString(",")
                var directionDic = [YearStatDirection: Int]()
                for (directionIndex, num) in directionArray.enumerate() {
                    if let direction = YearStatDirection(rawValue: directionIndex), stat = num.toUInt() {
                        directionDic[direction] = Int(stat)
                    }
                }
                monthDic[month] = directionDic
            }
        }
        return monthDic
    }
    
}
