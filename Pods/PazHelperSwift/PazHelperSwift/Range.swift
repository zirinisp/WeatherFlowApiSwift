//
//  Range.swift
//  ExSwift
//
//  Created by pNre on 04/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation
//import PazHelperSwift

internal extension CountableClosedRange {
    
    /**
    For each element in the range invokes function.
    
    - parameter function: Function to call
    */
    func times (_ function: @escaping () -> ()) {
        each { (current: Element) -> () in
            function()
        }
    }
    
    /**
    For each element in the range invokes function passing the element as argument.
    
    - parameter function: Function to invoke
    */
    func times (_ function: (Element) -> ()) {
        each (function)
    }
    
    /**
    For each element in the range invokes function passing the element as argument.
    
    - parameter function: Function to invoke
    */
    func each (_ function: (Element) -> ()) {
        for i in self {
            function(i)
        }
    }
    
    /**
    Range of Int with random bounds between from and to (inclusive).
    
    - parameter from: Lower bound
    - parameter to: Upper bound
    - returns: Random range
    */
    static func random (_ from: Int, to: Int) -> CountableClosedRange<Int> {
        
        let lowerBound = Int.random(from, max: to)
        let upperBound = Int.random(lowerBound, max: to)
        
        return lowerBound...upperBound
        
    }
    
    /**
    Returns each element of the range in an array
    
    - returns: Each element of the range in an array
    */
    func toArray () -> [Element] {
        var result: [Element] = []
        for i in self {
            result.append(i)
        }
        return result
    }
}

/**
*  Operator == to compare 2 ranges first, second by start & end indexes. If first.startIndex is equal to
*  second.startIndex and first.endIndex is equal to second.endIndex the ranges are considered equal.
*/
public func == <U: Comparable> (first: Range<U>, second: Range<U>) -> Bool {
    return first.lowerBound == second.lowerBound &&
        first.upperBound == second.upperBound
}

/**
*  DP2 style open range operator
*/
//public func .. <U : Comparable> (first: U, second: U) -> HalfOpenInterval<U> {
//    return first..<second
//}

