//
//  PazUnitManager.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 17/10/2014.
//  Copyright (c) 2014 paz-labs. All rights reserved.
//


import Foundation


public struct PazUnit <Unit: PazUnitProtocol> : Comparable {
    
    public static func NotificationUnitUpdate() -> Notification.Name { return Notification.Name("UnitUpdateNotification"+Unit.unitName) }
    
    private var _value : Double = 0.0
    public init(localValue: Double?) {
        _value = Unit.convert((localValue ?? 0.0), fromUnit: Unit.local, toUnit: Unit.storage)
    }
    public init(storageValue: Double?) {
        _value = storageValue ?? 0.0
    }
    public init (_ value: Double?, unit: Unit.UnitType) {
        let storageValue = Unit.convert((value ?? 0.0), fromUnit: unit, toUnit: Unit.storage)
        _value = storageValue
    }
    public var storageValue : Double {
        get {
            return _value
        }
        /* Commenting out setters as it might cause trouble with assignments. .value.storage = x. And value's setter will not be called
        set {
        _value = newValue
        }*/
    }
    public var localValue : Double {
        get {
            return Unit.convert(self.storageValue, fromUnit: Unit.storage, toUnit: Unit.local)
        }
        /*
        set {
        self.storageValue = Unit.convert(newValue, fromUnit: Unit.local, toUnit: Unit.storage)
        }*/
    }
    /*
    mutating func set (value: Double, unit: Unit.UnitType) {
    let storageValue = Unit.convert(value, fromUnit: unit, toUnit: Unit.storage)
    _value = storageValue
    }*/
    public func get (_ unit : Unit.UnitType) -> Double {
        return Unit.convert(self.storageValue, fromUnit: Unit.storage, toUnit: unit)
    }
}

public func < <T>(left: PazUnit<T>, right: PazUnit<T>) -> Bool {
    return left.storageValue < right.storageValue
}

public func > <T>(left: PazUnit<T>, right: PazUnit<T>) -> Bool {
    return left.storageValue > right.storageValue
}

public func <= <T>(left: PazUnit<T>, right: PazUnit<T>) -> Bool {
    return left.storageValue <= right.storageValue
}

public func >= <T>(left: PazUnit<T>, right: PazUnit<T>) -> Bool {
    return left.storageValue >= right.storageValue
}

public func == <T>(left: PazUnit<T>, right: PazUnit<T>) -> Bool {
    return left.storageValue == right.storageValue
}

public func * <T>(left: PazUnit<T>, right: Double) -> PazUnit<T> {
    let result = left.storageValue * right
    return PazUnit<T>(storageValue: result)
}

public func + <T>(left: PazUnit<T>, right: PazUnit<T>) -> PazUnit<T> {
    let result = left.storageValue + right.storageValue
    return PazUnit<T>(storageValue: result)
}

public protocol PazUnitProtocol {
    associatedtype UnitType
    static func convert (_ value : Double, fromUnit: UnitType, toUnit: UnitType) -> Double;
    static var local : UnitType { get set }
    static var storage : UnitType { get set }
    var description : String { get }
    static var unitName: String { get }  // This name will also be used to get the default value from user defaults.
}

// MARK: Speed
public enum PazUnitSpeed : Int, PazUnitProtocol {
    case Mph
    case Kts
    case Kph
    case Mps
    case Bft
    
    public static let allValues = [Mph, Kts, Kph, Mps, Bft]
    
    private static let KnotToKlm   = 1.852
    private static let KnotToMile  = 1.15077945
    private static let KnotToMps   = 0.51444
    
    public static func convert(_ value : Double, fromUnit: PazUnitSpeed, toUnit: PazUnitSpeed) -> Double {
        if (fromUnit == toUnit) {
            return value
        }
        var windSpeedKnots : Double = value
        switch fromUnit {
        case .Kph:
            windSpeedKnots = value / KnotToKlm
        case .Mph:
            windSpeedKnots = value / KnotToMile
        case .Kts:
            windSpeedKnots = value
        case .Mps:
            windSpeedKnots = value / KnotToMps
        case .Bft:
            windSpeedKnots = PazUnitSpeed.bftToKnots(Int(value))
        }
        switch toUnit {
        case .Kph:
            return windSpeedKnots * KnotToKlm
        case .Mph:
            return  windSpeedKnots * KnotToMile
        case .Kts:
            return windSpeedKnots
        case .Mps:
            return windSpeedKnots * KnotToMps
        case .Bft:
            return PazUnitSpeed.knotsToBft(windSpeedKnots).doubleValue()
        }
    }
    public static var unitName = "PazUnitSpeed"
    private static var defaultLocal = PazUnitSpeed.Kts
    public static var local : PazUnitSpeed {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitSpeed(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitSpeed>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitSpeed.Kts
    public static var storage : PazUnitSpeed {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitSpeed(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitSpeed>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Kph:
            return "Kph"
        case .Kts:
            return "Kts"
        case .Mph:
            return "Mph"
        case .Mps:
            return "Mps"
        case .Bft:
            return "Bft"
        }
    }
    // MARK: Bft scale
    // Helpers for Bft - Kts
    static func bftToKnots(_ bft: Int) -> Double {
        switch bft {
        case 0:     return 0.0
        case 1:     return 2.0
        case 2:     return 5.0
        case 3:     return 10.0
        case 4:     return 13.0
        case 5:     return 19.0
        case 6:     return 24.5
        case 7:     return 30.5
        case 8:     return 37.0
        case 9:     return 44.0
        case 10:     return 51.5
        case 11:     return 59.5
        default:     return 64.0
        }
    }
    static func knotsToBft(_ kts: Double) -> Int {
        if (kts <= 1) {
            return 0;
        } else if (kts <= 3.0) {
            return 1;
        } else if (kts <= 6.0) {
            return 2;
        } else if (kts <= 10.0) {
            return 3;
        } else if (kts <= 16.0) {
            return 4;
        } else if (kts <= 21.0) {
            return 5;
        } else if (kts <= 27.0) {
            return 6;
        } else if (kts <= 33.0) {
            return 7;
        } else if (kts <= 40.0) {
            return 8;
        } else if (kts <= 47.0) {
            return 9;
        } else if (kts <= 55.0) {
            return 10;
        } else if (kts <= 63.0) {
            return 11;
        } else {
            return 12;
        }
    }
}

public enum PazUnitDistance  : Int, PazUnitProtocol {
    case Km
    case Mile
    case Meters
    
    public static let allValues = [Km, Mile, Meters]
    
    private static let KmToMiles   = 0.621371
    
    public static func convert(_ value : Double, fromUnit: PazUnitDistance, toUnit: PazUnitDistance) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        var distanceKm : Double = value
        switch fromUnit {
        case .Mile:
            distanceKm = value / KmToMiles
        case .Meters:
            distanceKm = value / 1000.0
        default:
            distanceKm = value
        }
        
        switch toUnit {
        case .Mile:
            return  distanceKm * KmToMiles
        case .Meters:
            return distanceKm * 1000.0
        default:
            return  distanceKm
        }
    }
    
    public static var unitName = "PazUnitDistance"
    private static var defaultLocal = PazUnitDistance.Km
    public static var local : PazUnitDistance {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitDistance(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitDistance>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitDistance.Km
    public static var storage : PazUnitDistance {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitDistance(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitDistance>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Km:
            return "Km"
        case .Mile:
            return "Mile"
        case .Meters:
            return "Meters"
        }
    }
    
}

public enum PazUnitTemp : Int, PazUnitProtocol {
    case C
    case F
    
    public static let allValues = [C,F]
    
    public static func convert(_ value: Double, fromUnit: PazUnitTemp, toUnit: PazUnitTemp) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        switch (fromUnit) {
        case .C:
            switch (toUnit) {
            case .F:
                return value * 1.8 + 32;
            default:
                return value;
            }
        case .F:
            switch (toUnit) {
            case .C:
                return (value - 32) / 1.8;
            default:
                return value;
            }
        }
        
    }
    public static var unitName = "PazUnitTemp"
    private static var defaultLocal = PazUnitTemp.C
    public static var local : PazUnitTemp {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitTemp(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitTemp>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitTemp.C
    public static var storage : PazUnitTemp {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitTemp(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitTemp>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        let tempSymbol = "˚"
        switch self {
        case .C:
            return "\(tempSymbol)C"
        case .F:
            return "\(tempSymbol)F"
        }
    }
}

public enum PazUnitWeight : Int, PazUnitProtocol {
    case Kg
    case Pounds
    
    public static let allValues = [Kg, Pounds]
    
    private static let KgToPounds  = 2.20462
    
    public static func convert(_ value: Double, fromUnit: PazUnitWeight, toUnit: PazUnitWeight) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        switch (fromUnit) {
        case .Kg:
            switch (toUnit) {
            case .Pounds:
                return value * KgToPounds;
            default:
                return value;
            }
        case .Pounds:
            switch (toUnit) {
            case .Kg:
                return value / KgToPounds;
            default:
                return value;
            }
        }
    }
    public static var unitName = "PazUnitWeight"
    private static var defaultLocal = PazUnitWeight.Kg
    public static var local : PazUnitWeight {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitWeight(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitWeight>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitWeight.Kg
    public static var storage : PazUnitWeight {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitWeight(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitWeight>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Kg:
            return "Kg"
        case .Pounds:
            return "Pounds"
        }
    }
}

public enum PazUnitWave: Int, PazUnitProtocol {
    case Meter
    case Feet
    
    private static let FeetToMeters  = 0.3048
    
    public static func convert(_ value: Double, fromUnit: PazUnitWave, toUnit: PazUnitWave) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        switch (fromUnit) {
        case .Feet:
            switch (toUnit) {
            case .Meter:
                return value * FeetToMeters;
            default:
                return value;
            }
        case .Meter:
            switch (toUnit) {
            case .Feet:
                return value / FeetToMeters;
            default:
                return value;
            }
        }
    }
    public static var unitName = "PazUnitWave"
    private static var defaultLocal = PazUnitWave.Feet
    public static var local : PazUnitWave {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitWave(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitWave>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitWave.Feet
    public static var storage : PazUnitWave {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitWave(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitWave>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Feet:
            return "f"
        case .Meter:
            return "m"
        }
    }
}

public enum PazUnitPrecipitation: Int, PazUnitProtocol {
    case Milimeter
    case Inch
    
    private static let InchToMm = 25.4
    
    public static func convert(_ value: Double, fromUnit: PazUnitPrecipitation, toUnit: PazUnitPrecipitation) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        switch (fromUnit) {
        case .Inch:
            switch (toUnit) {
            case .Milimeter:
                return value * InchToMm;
            default:
                return value;
            }
        case .Milimeter:
            switch (toUnit) {
            case .Inch:
                return value / InchToMm
            default:
                return value
            }
        }
    }
    public static var unitName = "PazUnitPrecipitation"
    private static var defaultLocal = PazUnitPrecipitation.Milimeter
    public static var local : PazUnitPrecipitation {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitPrecipitation(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitPrecipitation>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitPrecipitation.Milimeter
    public static var storage : PazUnitPrecipitation {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitPrecipitation(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitPrecipitation>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Milimeter:
            return "mm"
        case .Inch:
            return "\""
        }
    }
    public var format: String {
        switch self {
        case .Inch:
            return "%.2f"
        case .Milimeter:
            return "%.1f"
        }
    }
}

public enum PazUnitPressure: Int, PazUnitProtocol {
    case Bar
    
    public static func convert(_ value: Double, fromUnit: PazUnitPressure, toUnit: PazUnitPressure) -> Double {
        return value;
    }
    public static var unitName = "PazUnitPressure"
    private static var defaultLocal = PazUnitPressure.Bar
    public static var local : PazUnitPressure {
        get  {
        if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Int {
        if let local = PazUnitPressure(rawValue: localRaw) {
        return local
        }
        }
        return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitPressure>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitPressure.Bar
    public static var storage : PazUnitPressure {
        get  {
        if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Int {
        if let storage = PazUnitPressure(rawValue: storageRaw) {
        return storage
        }
        }
        return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitPressure>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        return ""
    }
}


public enum PazUnitAngle: Double, PazUnitProtocol {
    case Radians
    case Degrees
    
    static func DEGREES_TO_RADIANS(_ angle: Double) -> Double {
        return ((angle) * 0.01745329252)
    }
    
    static func RADIANS_TO_DEGREES(_ angle: Double) -> Double {
        return ((angle) * 57.29577951)
    }
    
    public static func convert(_ value: Double, fromUnit: PazUnitAngle, toUnit: PazUnitAngle) -> Double {
        if (fromUnit == toUnit) {
            return value;
        }
        switch (fromUnit) {
        case .Radians:
            switch (toUnit) {
            case .Degrees:
                return RADIANS_TO_DEGREES(value)
            default:
                return value;
            }
        case .Degrees:
            switch (toUnit) {
            case .Radians:
                return DEGREES_TO_RADIANS(value)
            default:
                return value
            }
        }
    }
    public static var unitName = "PazUnitAngle"
    private static var defaultLocal = PazUnitAngle.Degrees
    public static var local : PazUnitAngle {
        get  {
            if let localRaw = UserDefaults.standard.object(forKey: "\(self.unitName)LocalKey") as? Double {
                if let local = PazUnitAngle(rawValue: localRaw) {
                    return local
                }
            }
            return self.defaultLocal
        }
        set {
            if self.local == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)LocalKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitAngle>.NotificationUnitUpdate(), object:nil)
        }
    }
    private static var defaultStorage = PazUnitAngle.Degrees
    public static var storage : PazUnitAngle {
        get  {
            if let storageRaw = UserDefaults.standard.object(forKey: "\(self.unitName)StorageKey") as? Double {
                if let storage = PazUnitAngle(rawValue: storageRaw) {
                    return storage
                }
            }
            return self.defaultStorage
        }
        set {
            if self.storage == newValue {
                return
            }
            let newValueRaw = newValue.rawValue
            UserDefaults.standard.set(newValueRaw, forKey: "\(self.unitName)StorageKey")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: PazUnit<PazUnitAngle>.NotificationUnitUpdate(), object:nil)
        }
    }
    public var description : String {
        switch self {
        case .Degrees:
            return "Degrees"
        case .Radians:
            return "Radians"
        }
    }
    public var format: String {
        switch self {
        case .Degrees:
            return "%.2f"
        case .Radians:
            return "%.4f"
        }
    }

}
