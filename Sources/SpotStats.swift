//
//  SpotStats.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 28/01/2016.
//  Copyright © 2016 Pantelis Zirinis. All rights reserved.
//


open class SpotStats {

    open fileprivate (set) var spot_id: Int!
    open fileprivate (set) var name: String?
    open fileprivate (set) var status: Status?
    open fileprivate (set) var start_month: String?
    open fileprivate (set) var year_stats: [YearStat]?
    
    public init?(spot_id: Int, dictionary: [String : Any]) {
        self.spot_id = spot_id
        self.name = (dictionary["name"] as? String)
        self.start_month = (dictionary["start_month"] as? String)
        if let statusDictionary = dictionary["status"] as? [String: Any] {
            self.status = Status(dictionary: statusDictionary)
        }
        var year_stats = [YearStat]()
        if let statistics = dictionary["year_stat"] as? [[String: Any]] {
            for yearStatDictionary in statistics {
                if let yearStat = YearStat(dictionary: yearStatDictionary) {
                    year_stats.append(yearStat)
                }
            }
        }
        self.year_stats = year_stats
    }

    open var valid: Bool {
        guard let year_stats = self.year_stats else {
            return false
        }
        return year_stats.count != 0
    }
}

public enum YearStatMonth: Int {
    case jan
    case feb
    case mar
    case apr
    case may
    case jun
    case jul
    case aug
    case sep
    case oct
    case nov
    case dec
    
    public static let AllValues: [YearStatMonth] = {
        return [.jan, .feb, .mar, .apr, .may, .jun, .jul, .aug, .sep, .oct, .nov, .dec]
    }()
}

public enum YearStatDirection: Int {
    case n
    case nne
    case ne
    case ene
    case e
    case ese
    case se
    case sse
    case s
    case ssw
    case sw
    case wsw
    case w
    case wnw
    case nw
    case nnw
    
    /// Initialize with direction in degrees
    public init?(direction: Int) {
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
    
    public static let count: Int = {
        var max: Int = 0
        while let _ = YearStatDirection(rawValue: max) { max += 1 }
        return max
    }()
}

open class YearStat {
    open fileprivate (set) var year: String!
    
    open fileprivate (set) var avg_t0: [YearStatMonth: Int]?
    open fileprivate (set) var avg_t5: [YearStatMonth: Int]?
    open fileprivate (set) var avg_t10: [YearStatMonth: Int]?
    open fileprivate (set) var avg_t15: [YearStatMonth: Int]?
    open fileprivate (set) var avg_t20: [YearStatMonth: Int]?
    open fileprivate (set) var avg_t25: [YearStatMonth: Int]?

    open fileprivate (set) var gust_t0: [YearStatMonth: Int]?
    open fileprivate (set) var gust_t5: [YearStatMonth: Int]?
    open fileprivate (set) var gust_t10: [YearStatMonth: Int]?
    open fileprivate (set) var gust_t15: [YearStatMonth: Int]?
    open fileprivate (set) var gust_t20: [YearStatMonth: Int]?
    open fileprivate (set) var gust_t25: [YearStatMonth: Int]?

    open fileprivate (set) var dir_avg_t0: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_avg_t5: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_avg_t10: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_avg_t15: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_avg_t20: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_avg_t25: [YearStatMonth: [YearStatDirection: Int]]?

    open fileprivate (set) var dir_gust_t0: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_gust_t5: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_gust_t10: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_gust_t15: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_gust_t20: [YearStatMonth: [YearStatDirection: Int]]?
    open fileprivate (set) var dir_gust_t25: [YearStatMonth: [YearStatDirection: Int]]?
    

    public init?(dictionary: [String : Any]) {
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
    
    class func convertStringToMonthDictionary(_ stringArray: String) -> [YearStatMonth: Int]? {
        var monthDic = [YearStatMonth: Int]()
        var string: String = stringArray
        string = string.replacingOccurrences(of: "[", with: "")
        string = string.replacingOccurrences(of: "]", with: "")
        string = string.replacingOccurrences(of: " ", with: "")

        let array = string.components(separatedBy: ",")
        for (index, numOfDays) in array.enumerated() {
            if let month = YearStatMonth(rawValue: index) {
                if let num = UInt(numOfDays) {
                    monthDic[month] = Int(num)
                }
            }
        }
        return monthDic
    }

    class func convertStringToMonthDirectionDictionary(_ inputString: String) -> [YearStatMonth: [YearStatDirection: Int]]? {
        let yearStringArray = inputString.components(separatedBy: "],")

        var monthDic = [YearStatMonth: [YearStatDirection: Int]]()
        for (monthIndex, monthStringArray) in yearStringArray.enumerated() {
            if let month = YearStatMonth(rawValue: monthIndex) {
                var string: String = monthStringArray
                string = string.replacingOccurrences(of: "[", with: "")
                string = string.replacingOccurrences(of: "]", with: "")
                string = string.replacingOccurrences(of: " ", with: "")
                
                let directionArray = string.components(separatedBy: ",")
                var directionDic = [YearStatDirection: Int]()
                for (directionIndex, num) in directionArray.enumerated() {
                    if let direction = YearStatDirection(rawValue: directionIndex), let stat = UInt(num) {
                        directionDic[direction] = Int(stat)
                    }
                }
                monthDic[month] = directionDic
            }
        }
        return monthDic
    }
    
}
