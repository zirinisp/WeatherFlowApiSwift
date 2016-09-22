

//import Darwin
import CoreGraphics
import UIKit


public protocol FloatingPointMathType {
    var acos:Self  {get}
    var asin:Self  {get}
    var atan:Self  {get}
    func atan2(x:Self) -> Self
    var cos:Self   {get}
    var sin:Self   {get}
    var tan:Self   {get}
    var exp:Self   {get}
    var exp2:Self  {get}
    var log:Self   {get}
    var log10:Self {get}
    var log2:Self  {get}
    func pow(exponent:Self) -> Self
    var sqrt:Self  {get}
}


extension Double :  FloatingPointMathType {
    public var abs:Double  { return Double.abs(self)   }
    public var acos:Double { return Darwin.acos(self)  }
    public var asin:Double { return Darwin.asin(self)  }
    public var atan:Double { return Darwin.atan(self)  }
    public func atan2(x:Double) -> Double { return Darwin.atan2(self,x) }
    public var cos:Double  { return Darwin.cos(self)   }
    public var sin:Double  { return Darwin.sin(self)   }
    public var tan:Double  { return Darwin.tan(self)   }
    public var exp:Double  { return Darwin.exp(self)   }
    public var exp2:Double { return Darwin.exp2(self)  }
    public var log:Double  { return Darwin.log(self)   }
    public var log10:Double{ return Darwin.log10(self) }
    public var log2:Double { return Darwin.log2(self)  }
    public func pow(exponent:Double)-> Double { return Darwin.pow(self, exponent) }
    public var sqrt:Double { return Darwin.sqrt(self)  }
    func __conversion() -> CGFloat { return CGFloat(self) }
}

extension Double: ScalarCGFloatType {
    public var toCGFloat: CGFloat {
        return CGFloat(self)
    }
    public func cgFloat() -> CGFloat {
        return CGFloat(self)
    }
    public func float() -> Float {
        return Float(self)
    }
    public func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
    /**
    Rounds self to the largest integer <= self.
    
    - returns: floor(self)
    */
    public func floor () -> Double {
        return Foundation.floor(self)
    }
    
    /**
    Rounds self to the smallest integer >= self.
    
    - returns: ceil(self)
    */
    public func ceil () -> Double {
        return Foundation.ceil(self)
    }
    
    /**
    Rounds self to the nearest integer.
    
    - returns: round(self)
    */
    public func round () -> Double {
        return Foundation.round(self)
    }
    
    /**
    Clamps self to a specified range.
    
    - parameter min: Lower bound
    - parameter max: Upper bound
    - returns: Clamped value
    */
    public func clamp (min: Double, _ max: Double) -> Double {
        return Swift.max(min, Swift.min(max, self))
    }
    
    /**
    Random double between min and max (inclusive).
    
    :params: min
    :params: max
    - returns: Random number
    */
    public static func random(min: Double = 0, max: Double) -> Double {
        let diff = max - min;
        let rand = Double(arc4random() % (UInt32(RAND_MAX) + 1))
        return ((rand / Double(RAND_MAX)) * diff) + min;
    }
}



public protocol ScalarFloatingPointType {
    var toDouble:Double { get }
    func doubleValue() -> Double // added for convenience as code exists with that function.
    init(_ value:Double)
}


extension CGFloat : ScalarFloatingPointType, FloatingPointMathType, ScalarCGFloatType {
    public var toDouble:Double  { return Double(self)      }
    public var abs:CGFloat      { return self.abs  }
    public var acos:CGFloat     { return Darwin.acos(self.toDouble).toCGFloat }
    public var asin:CGFloat     { return Darwin.asin(self.toDouble).toCGFloat }
    public var atan:CGFloat     { return Darwin.atan(self.toDouble).toCGFloat }
    public func atan2(x:CGFloat) -> CGFloat { return Darwin.atan2(self.toDouble, x.toDouble).toCGFloat }
    public var cos:CGFloat      { return Darwin.cos(self.toDouble).toCGFloat  }
    public var sin:CGFloat      { return Darwin.sin(self.toDouble).toCGFloat  }
    public var tan:CGFloat      { return Darwin.tan(self.toDouble).toCGFloat  }
    public var exp:CGFloat      { return Darwin.exp(self.toDouble).toCGFloat  }
    public var exp2:CGFloat     { return Darwin.exp2(self.toDouble).toCGFloat }
    public var log:CGFloat      { return Darwin.log(self.toDouble).toCGFloat  }
    public var log10:CGFloat    { return Darwin.log10(self.toDouble).toCGFloat}
    public var log2:CGFloat     { return Darwin.log2(self.toDouble).toCGFloat}
    public func pow(exponent:CGFloat)-> CGFloat { return Darwin.pow(self.toDouble, exponent.toDouble).toCGFloat }
    public var sqrt:CGFloat     { return Darwin.sqrt(self.toDouble).toCGFloat }
    func __conversion() -> Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self) }
    public var toCGFloat: CGFloat { return self }
}

extension Float : ScalarFloatingPointType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self)      }
    public func doubleValue() -> Double { return Double(self)      }
    public var toCGFloat: CGFloat { return CGFloat(self) }
}

public protocol ScalarIntegerType : ScalarFloatingPointType {
    var toInt:Int { get }
}

extension Int : ScalarIntegerType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toInt:Int { return Int(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension Int16 : ScalarIntegerType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toInt:Int { return Int(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension Int32 : ScalarIntegerType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toInt:Int { return Int(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension Int64 : ScalarIntegerType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toInt:Int { return Int(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension UInt : ScalarFloatingPointType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension UInt16  : ScalarFloatingPointType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
}
extension UInt32 : ScalarFloatingPointType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
}
extension UInt64 : ScalarFloatingPointType, ScalarCGFloatType {
    public var toDouble:Double { return Double(self) }
    public func doubleValue() -> Double { return Double(self)      }
    func __conversion() -> Double { return Double(self) }
    public var toCGFloat: CGFloat { return CGFloat(self) }
}

extension Bool {
    public func intValue() -> Int {
        if self {return 1} else {return 0}
    }
}


/* Ambiguous Use
func + <T:ScalarIntegerType>(lhs:T, rhs:Int) -> Int { return lhs + rhs }
func + <T:ScalarIntegerType>(lhs:Int, rhs:T) -> Int { return lhs + rhs.toInt }

func - <T:ScalarIntegerType>(lhs:T, rhs:Int) -> Int { return lhs.toInt - rhs }
func - <T:ScalarIntegerType>(lhs:Int, rhs:T) -> Int { return lhs - rhs.toInt }

func * <T:ScalarIntegerType>(lhs:T, rhs:Int) -> Int { return lhs.toInt * rhs }
func * <T:ScalarIntegerType>(lhs:Int, rhs:T) -> Int { return lhs * rhs.toInt }

func / <T:ScalarIntegerType>(lhs:T, rhs:Int) -> Int { return lhs.toInt / rhs }
func / <T:ScalarIntegerType>(lhs:Int, rhs:T) -> Int { return lhs / rhs.toInt }
*/

// When both lhd and rhd are the same type I get ambiguous error, so I removed them

//Equality T<===>T
//func == <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:U,rhs:T) -> Bool { return (lhs.toDouble == rhs.toDouble) }
public func == <T:ScalarFloatingPointType> (lhs:Double,rhs:T) -> Bool { return (lhs == rhs.toDouble) }
public func == <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs.toDouble == rhs) }

//func != <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:U,rhs:T) -> Bool { return (lhs.toDouble == rhs.toDouble) == false }
public func != <T:ScalarFloatingPointType> (lhs:Double,rhs:T) -> Bool { return (lhs == rhs.toDouble) == false }
public func != <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs.toDouble == rhs) == false }

//func <= <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:T,rhs:U) -> Bool { return (lhs.toDouble <= rhs.toDouble) }
public func <= <T:ScalarFloatingPointType> (lhs:Double, rhs:T) -> Bool { return (lhs <= rhs.toDouble) }
public func <= <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs.toDouble <= rhs) }

//func < <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:T,rhs:U) -> Bool { return (lhs.toDouble <  rhs.toDouble) }
public func < <T:ScalarFloatingPointType> (lhs:Double, rhs:T) -> Bool { return (lhs <  rhs.toDouble) }
public func < <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs.toDouble <  rhs) }

//func >  <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:T,rhs:U) -> Bool { return (lhs <= rhs) == false }
public func >  <T:ScalarFloatingPointType> (lhs:Double, rhs:T) -> Bool { return (lhs <= rhs) == false}
public func >  <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs <= rhs) == false }

//func >= <T:ScalarFloatingPointType, U:ScalarFloatingPointType> (lhs:T,rhs:U) -> Bool { return (lhs < rhs) == false }
public func >= <T:ScalarFloatingPointType> (lhs:Double, rhs:T) -> Bool { return (lhs < rhs) == false }
public func >= <T:ScalarFloatingPointType> (lhs:T,rhs:Double) -> Bool { return (lhs < rhs) == false }



//SUBTRACTION
//func - <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(lhs:U, rhs:T) -> Double  {return (lhs.toDouble - rhs.toDouble) }
public func - <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> T  { return T(lhs - rhs.toDouble) }
public func - <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> T  { return T(lhs.toDouble - rhs) }
public func - <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> Double  { return (lhs - rhs.toDouble) }
public func - <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> Double  { return (lhs.toDouble - rhs) }
//public func -= <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(inout lhs:T, rhs:U) { lhs = T(lhs.toDouble - rhs.toDouble) }
public func -= <T:ScalarFloatingPointType>(lhs:inout Double, rhs:T)  { lhs = lhs - rhs.toDouble }

//ADDITION
//public func + <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(lhs:U, rhs:T) -> Double  {return (lhs.toDouble + rhs.toDouble) }
public func + <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> T  { return T(lhs + rhs.toDouble) }
public func + <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> T  { return T(lhs.toDouble + rhs) }
public func + <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> Double  { return (lhs + rhs.toDouble) }
public func + <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> Double  { return (lhs.toDouble + rhs) }
//public func += <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(inout lhs:T, rhs:U) { lhs = T(lhs.toDouble + rhs.toDouble) }
public func += <T:ScalarFloatingPointType>(lhs:inout Double, rhs:T)  { lhs = lhs + rhs.toDouble }
public func += <T:ScalarFloatingPointType>(lhs:inout T, rhs:Double) { lhs = T(lhs.toDouble + rhs) } // TODO: If it works add it to others

//MULTIPLICATION
//public func * <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(lhs:U, rhs:T) -> Double  {return (lhs.toDouble * rhs.toDouble) }
public func * <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> T  { return T(lhs * rhs.toDouble) }
public func * <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> T  { return T(lhs.toDouble * rhs) }
public func * <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> Double  { return (lhs * rhs.toDouble) }
public func * <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> Double  { return (lhs.toDouble * rhs) }
//public func *= <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(inout lhs:T, rhs:U) { lhs = T(lhs.toDouble * rhs.toDouble) }
public func *= <T:ScalarFloatingPointType>(lhs:inout Double, rhs:T)  { lhs = lhs * rhs.toDouble }

//DIVISION
//public func / <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(lhs:U, rhs:T) -> Double  {return (lhs.toDouble / rhs.toDouble) }
public func / <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> T  { return T(lhs / rhs.toDouble) }
public func / <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> T  { return T(lhs.toDouble / rhs) }
public func / <T:ScalarFloatingPointType>(lhs:Double, rhs:T) -> Double  { return (lhs / rhs.toDouble) }
public func / <T:ScalarFloatingPointType>(lhs:T, rhs:Double) -> Double  { return (lhs.toDouble / rhs) }
//public func /= <T:ScalarFloatingPointType, U:ScalarFloatingPointType>(inout lhs:T, rhs:U) { lhs = T(lhs.toDouble / rhs.toDouble) }
public func /= <T:ScalarFloatingPointType>(lhs:inout Double, rhs:T)  { lhs = lhs / rhs.toDouble }



public protocol ScalarCGFloatType {
    var toCGFloat: CGFloat { get }
}

public func CGRectMake(_ x: ScalarCGFloatType, _ y: ScalarCGFloatType, _ width: ScalarCGFloatType, _ height: ScalarCGFloatType) -> CGRect {
    return CGRect(x: x.toCGFloat, y: y.toCGFloat, width: width.toCGFloat, height: height.toCGFloat)
}

public func CGSizeMake(_ width: ScalarCGFloatType, height: ScalarCGFloatType) -> CGSize {
    return CGSize(width: width.toCGFloat, height: height.toCGFloat)
}

public func UIEdgeInsetsMake(_ top: ScalarCGFloatType, _ left:ScalarCGFloatType, _ bottom: ScalarCGFloatType, _ right: ScalarCGFloatType) -> UIEdgeInsets {
    return UIEdgeInsetsMake(top.toCGFloat, left.toCGFloat, bottom.toCGFloat, right.toCGFloat)
}

// Equal on double
infix operator ~==


public func ~== (lhs: Double, rhs: Double) -> Bool {
    let dif = abs(lhs - rhs)
    if dif < 0.001 {
        return true
    }
    return false
}

public func ~== (lhs: CGFloat, rhs: CGFloat) -> Bool {
    let dif = abs(lhs - rhs)
    if dif < 0.001 {
        return true
    }
    return false
}


public func ~== (lhs: CGRect, rhs: CGRect) -> Bool {
    return (lhs.origin.x ~== rhs.origin.x) && (lhs.origin.y ~== rhs.origin.y) && (lhs.size.width ~== rhs.size.width) && (lhs.size.height ~== rhs.size.height)
}

public extension Double {
    public func roundToDecimalPlaces(_ decimalPlaces: Int) -> Double {
        let multiplier: Double = 4 * 10
        return (self * multiplier).round() / multiplier
    }
}
