//
//  Array.swift
//  ExSwift
//
//  Created by pNre on 03/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


internal extension Array {
    
    
    /// Add item if not nil
    mutating func appendIf(_ item: Element?) {
        if let letItem = item {
            self.append(letItem)
        }
    }
    
    fileprivate var indexesInterval: CountableRange<Int> { return (0 ..< self.count) }
    
    /**
    Checks if self contains a list of items.
    
    - parameter items: Items to search for
    - returns: true if self contains all the items
    */
    func contains <Element: Equatable> (_ items: Element...) -> Bool {
        return items.all { (item: Element) -> Bool in self.indexOf(item) >= 0 }
    }
    
    /**
    Difference of self and the input arrays.
    
    - parameter values: Arrays to subtract
    - returns: Difference of self and the input arrays
    */
    func difference <Element: Equatable> (_ values: [Element]...) -> [Element] {
        
        var result = [Element]()
        
        elements: for e in self {
            if let element = e as? Element {
                for value in values {
                    //  if a value is in both self and one of the values arrays
                    //  jump to the next iteration of the outer loop
                    if value.contains(element) {
                        continue elements
                    }
                }
                
                //  element it's only in self
                result.append(element)
            }
        }
        
        return result
        
    }
    
    /**
    Intersection of self and the input arrays.
    
    - parameter values: Arrays to intersect
    - returns: Array of unique values contained in all the dictionaries and self
    */
    func intersection <U: Equatable> (_ values: [U]...) -> Array {
        
        var result = self
        var intersection = Array()
        
        for (i, value) in values.enumerated() {
            
            //  the intersection is computed by intersecting a couple per loop:
            //  self n values[0], (self n values[0]) n values[1], ...
            if (i > 0) {
                result = intersection
                intersection = Array()
            }
            
            //  find common elements and save them in first set
            //  to intersect in the next loop
            value.each { (item: U) -> Void in
                if result.contains(item) {
                    intersection.append(item as! Element)
                }
            }
            
        }
        
        return intersection
        
    }
    
    /**
    Union of self and the input arrays.
    
    - parameter values: Arrays
    - returns: Union array of unique values
    */
    func union <U: Equatable> (_ values: [U]...) -> Array {
        
        var result = self
        
        for array in values {
            for value in array {
                if !result.contains(value) {
                    result.append(value as! Element)
                }
            }
        }
        
        return result
        
    }
    
    /**
    First element of the array.
    
    - returns: First element of the array if not empty
    */
    @available(*, unavailable, message: "use the 'first' property instead") func first () -> Element? {
        return first
    }
    
    /**
    Last element of the array.
    
    - returns: Last element of the array if not empty
    */
    @available(*, unavailable, message: "use the 'last' property instead") func last () -> Element? {
        return last
    }
    
    /**
    First occurrence of item, if found.
    
    - parameter item: The item to search for
    - returns: Matched item or nil
    */
    func find <U: Equatable> (_ item: U) -> Element? {
        if let index: Int = indexOf(item) {
            return self[index]
        }
        
        return nil
    }
    
    /**
    First item that meets the condition.
    
    - parameter condition: A function which returns a boolean if an element satisfies a given condition or not.
    - returns: First matched item or nil
    */
    func find (_ condition: (Element) -> Bool) -> Element? {
        return takeFirst(condition)
    }
    
    /**
    Index of the first occurrence of item, if found.
    
    - parameter item: The item to search for
    - returns: Index of the matched item or nil
    */
    func indexOf <U: Equatable> (_ item: U) -> Int? {
        if item is Element {
            return self.index(where: { (object) -> Bool in
                return (object as! U) == item
            })
        }
        
        return nil
    }
    
    /**
    Gets the index of the last occurrence of item, if found.
    
    - parameter item: The item to search for
    - returns: Index of the matched item or nil
    */
    func lastIndexOf <U: Equatable> (_ item: U) -> Int? {
        if item is Element {
            for (index, value) in self.reversed().enumerated() {
                if value as! U == item {
                    return count - 1 - index
                }
            }
            
            return nil
        }
        
        return nil
    }
    
    /**
    Gets the object at the specified index, if it exists.
    
    - parameter index:
    - returns: Object at index in self
    */
    func get (_ index: Int) -> Element? {
        
        return index >= 0 && index < count ? self[index] : nil
        
    }
    
    /**
    Gets the objects in the specified range.
    
    - parameter range:
    - returns: Subarray in range
    */
    /* Swift 3.0 does not compile
    func get (_ range: Range<Int>) -> Array {
        
        return Array(self[range])
        
    }*/
    
    /**
    Returns an array of grouped elements, the first of which contains the first elements
    of the given arrays, the 2nd contains the 2nd elements of the given arrays, and so on.
    
    - parameter arrays: Arrays to zip
    - returns: Array of grouped elements
    */
    func zip (_ arrays: Any...) -> [[Any?]] {
        
        var result = [[Any?]]()
        
        //  Gets the longest sequence
        let max = arrays.map { (element: Any) -> Int in
            return Int(Mirror(reflecting: element).children.count)
            }.max() as Int
        
        for i in 0..<max {
            
            //  i-th element in self as array + every i-th element in each array in arrays
            result.append([get(i)] + arrays.map { (element) -> Any? in
                // let (_, mirror) = reflect(element)[i]
                // return mirror.value
                return Mirror(reflecting: element).children
                })
            
        }
        
        return result
    }
    
    
    /**
    Applies cond to each element in array, splitting it each time cond returns a new value.
    
    - parameter cond: Function which takes an element and produces an equatable result.
    - returns: Array partitioned in order, splitting via results of cond.
    */
    func partitionBy <Element: Equatable> (_ cond: (Element) -> Element) -> [Array] {
        var result = [Array]()
        var lastValue: Element? = nil
        
        for item in self {
            let value = cond(item as! Element)
            
            if value == lastValue {
                let index: Int = result.count - 1
                result[index] += [item]
            } else {
                result.append([item])
                lastValue = value
            }
        }
        
        return result
    }
    
    /**
    Randomly rearranges the elements of self using the Fisher-Yates shuffle
    */
    mutating func shuffle () {
        
        for i in stride(from: (self.count - 1), through: 1, by: -1) {
            let j = Int.random(max: i)
            swap(&self[i], &self[j])
        }
        
    }
    
    /**
    Shuffles the values of the array into a new one
    
    - returns: Shuffled copy of self
    */
    func shuffled () -> Array {
        var shuffled = self
        
        shuffled.shuffle()
        
        return shuffled
    }
    
    /**
    Returns a random subarray of given length.
    
    - parameter n: Length
    - returns: Random subarray of length n
    */
    func sample (size n: Int = 1) -> Array {
        if n >= count {
            return self
        }
        
        let index = Int.random(max: count - n)
        return Array(self[index...(n + index - 1)])
    }
    
    /**
    Max value in the current array (if Array.Element implements the Comparable protocol).
    
    - returns: Max value
    */
    func max <U: Comparable> () -> U {
        
        return map {
            return $0 as! U
            }.max()!
        
    }
    
    /**
    Min value in the current array (if Array.Element implements the Comparable protocol).
    
    - returns: Min value
    */
    func min <U: Comparable> () -> U {
        
        return map {
            return $0 as! U
            }.min()!
        
    }
    
    /**
    The value for which call(value) is highest.
    - returns: Max value in terms of call(value)
    */
    func maxBy <U: Comparable> (_ call: (Element) -> (U)) -> Element? {
        
        if let firstValue = self.first {
            var maxElement: Element = firstValue
            var maxValue: U = call(firstValue)
            for i in 1..<self.count {
                let element: Element = self[i]
                let value: U = call(element)
                if value > maxValue {
                    maxElement = element
                    maxValue = value
                }
            }
            return maxElement
        } else {
            return nil
        }
        
    }
    
    /**
    The value for which call(value) is lowest.
    - returns: Min value in terms of call(value)
    */
    func minBy <U: Comparable> (_ call: (Element) -> (U)) -> Element? {
        
        if let firstValue = self.first {
            var minElement: Element = firstValue
            var minValue: U = call(firstValue)
            for i in 1..<self.count {
                let element: Element = self[i]
                let value: U = call(element)
                if value < minValue {
                    minElement = element
                    minValue = value
                }
            }
            return minElement
        } else {
            return nil
        }
        
    }
    
    /**
    Iterates on each element of the array.
    
    - parameter call: Function to call for each element
    */
    func each (_ call: (Element) -> ()) {
        
        for item in self {
            call(item)
        }
        
    }
    
    /**
    Iterates on each element of the array with its index.
    
    - parameter call: Function to call for each element
    */
    func each (_ call: (Int, Element) -> ()) {
        
        for (index, item) in self.enumerated() {
            call(index, item)
        }
        
    }
    
    /**
    Iterates on each element of the array from Right to Left.
    
    - parameter call: Function to call for each element
    */
    @available(*, unavailable, message: "use 'reverse().each' instead") func eachRight (_ call: (Element) -> ()) {
        reversed().each(call)
    }
    
    /**
    Iterates on each element of the array, with its index, from Right to Left.
    
    - parameter call: Function to call for each element
    */
    @available(*, unavailable, message: "use 'reverse().each' instead") func eachRight (_ call: (Int, Element) -> ()) {
        for (index, item) in reversed().enumerated() {
            call(count - index - 1, item)
        }
    }
    
    /**
    Checks if test returns true for any element of self.
    
    - parameter test: Function to call for each element
    - returns: true if test returns true for any element of self
    */
    func any (_ test: (Element) -> Bool) -> Bool {
        for item in self {
            if test(item) {
                return true
            }
        }
        
        return false
    }
    
    /**
    Checks if test returns true for all the elements in self
    
    - parameter test: Function to call for each element
    - returns: True if test returns true for all the elements in self
    */
    func all (_ test: (Element) -> Bool) -> Bool {
        for item in self {
            if !test(item) {
                return false
            }
        }
        
        return true
    }
    
    /**
    Opposite of filter.
    
    - parameter exclude: Function invoked to test elements for the exclusion from the array
    - returns: Filtered array
    */
    func reject (_ exclude: ((Element) -> Bool)) -> Array {
        return filter {
            return !exclude($0)
        }
    }
    
    /**
    Returns an array containing the first n elements of self.
    
    - parameter n: Number of elements to take
    - returns: First n elements
    */
    func take (_ n: Int) -> Array {
        return Array(self[0...Swift.max(0, (n-1))])
    }
    
    /**
    Returns the elements of the array up until an element does not meet the condition.
    
    - parameter condition: A function which returns a boolean if an element satisfies a given condition or not.
    - returns: Elements of the array up until an element does not meet the condition
    */
    func takeWhile (_ condition: (Element) -> Bool) -> Array {
        
        var lastTrue = -1
        
        for (index, value) in self.enumerated() {
            if condition(value) {
                lastTrue = index
            } else {
                break
            }
        }
        
        return take(lastTrue + 1)
        
    }
    
    /**
    Returns the first element in the array to meet the condition.
    
    - parameter condition: A function which returns a boolean if an element satisfies a given condition or not.
    - returns: The first element in the array to meet the condition
    */
    func takeFirst (_ condition: (Element) -> Bool) -> Element? {
        
        for value in self {
            if condition(value) {
                return value
            }
        }
        
        return nil
        
    }
    
    /**
    Returns an array containing the the last n elements of self.
    
    - parameter n: Number of elements to take
    - returns: Last n elements
    */
    func tail (_ n: Int) -> Array {
        
        return  Array(self[(count - n)...(count-1)])
        
    }
    
    /**
    Subarray from n to the end of the array.
    
    - parameter n: Number of elements to skip
    - returns: Array from n to the end
    */
    func skip (_ n: Int) -> Array {
        
        return n > count ? [] : Array(self[Int(n)...(count-1)])
        
    }
    
    /**
    Skips the elements of the array up until the condition returns false.
    - parameter condition: A function which returns a boolean if an element satisfies a given condition or not
    - returns: Elements of the array starting with the element which does not meet the condition
    */
    func skipWhile (_ condition: (Element) -> Bool) -> Array {
        
        var lastTrue = -1
        
        for (index, value) in self.enumerated() {
            if condition(value) {
                lastTrue = index
            } else {
                break
            }
        }
        
        return skip(lastTrue + 1)
    }
    
    /**
    Costructs an array removing the duplicate values in self
    if Array.Element implements the Equatable protocol.
    
    - returns: Array of unique values
    */
    func unique <Element: Equatable> () -> [Element] {
        var result = [Element]()
        
        for item in self {
            if !result.contains(item as! Element) {
                result.append(item as! Element)
            }
        }
        
        return result
    }
    
    /**
    Returns the set of elements for which call(element) is unique
    
    - parameter call: The closure to use to determine uniqueness
    - returns: The set of elements for which call(element) is unique
    */
    func uniqueBy <Element: Equatable> (_ call: (Element) -> (Element)) -> [Element] {
        var result: [Element] = []
        var uniqueItems: [Element] = []
        
        for item in self {
            let callResult: Element = call(item as! Element)
            if !uniqueItems.contains(callResult) {
                uniqueItems.append(callResult)
                result.append(item as! Element)
            }
        }
        
        return result
    }
    
    /**
    Returns all permutations of a given length within an array
    
    - parameter length: The length of each permutation
    - returns: All permutations of a given length within an array
    */
    func permutation (_ length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        } else if length == 0 {
            return [[]]
        } else {
            var permutations: [[Element]] = []
            let combinations = combination(length)
            for combination in combinations {
                var endArray: [[Element]] = []
                var mutableCombination = combination
                permutations += self.permutationHelper(length, array: &mutableCombination, endArray: &endArray)
            }
            return permutations
        }
    }
    
    /**
    Recursive helper method where all of the permutation-generating work is done
    This is Heap's algorithm
    */
    fileprivate func permutationHelper(_ n: Int, array: inout [Element], endArray: inout [[Element]]) -> [[Element]] {
        if n == 1 {
            endArray += [array]
        }
        for i in 0 ..< n {
            let _ = permutationHelper(n - 1, array: &array, endArray: &endArray)
            let j = n % 2 == 0 ? i : 0;
            //(array[j], array[n - 1]) = (array[n - 1], array[j])
            let temp: Element = array[j]
            array[j] = array[n - 1]
            array[n - 1] = temp
        }
        return endArray
    }
    
    /**
    Creates a dictionary composed of keys generated from the results of
    running each element of self through groupingFunction. The corresponding
    value of each key is an array of the elements responsible for generating the key.
    
    - parameter groupingFunction:
    - returns: Grouped dictionary
    */
    func groupBy <U> (groupingFunction group: (Element) -> U) -> [U: Array] {
        
        var result = [U: Array]()
        
        for item in self {
            
            let groupKey = group(item)
            
            // If element has already been added to dictionary, append to it. If not, create one.
            if result.has(groupKey) {
                result[groupKey]! += [item]
            } else {
                result[groupKey] = [item]
            }
        }
        
        return result
    }
    
    /**
    Similar to groupBy, instead of returning a list of values,
    returns the number of values for each group.
    
    - parameter groupingFunction:
    - returns: Grouped dictionary
    */
    func countBy <U> (groupingFunction group: (Element) -> U) -> [U: Int] {
        
        var result = [U: Int]()
        
        for item in self {
            let groupKey = group(item)
            
            if result.has(groupKey) {
                result[groupKey]! += 1
            } else {
                result[groupKey] = 1
            }
        }
        
        return result
    }
    
    /**
    Returns all of the combinations in the array of the given length, allowing repeats
    
    - parameter length:
    - returns: Combinations
    */
    func repeatedCombination (_ length: Int) -> [[Element]] {
        if length < 0 {
            return []
        }
        
        var indexes: [Int] = []
        length.times {
            indexes.append(0)
        }
        
        var combinations: [[Element]] = []
        
        while true {
            var combination: [Element] = []
            for index in indexes {
                combination.append(self[index])
            }
            combinations.append(combination)
            var i = indexes.count - 1
            while i >= 0 && indexes[i] == self.count - 1 {
                i -= 1
            }
            if i < 0 {
                break
            }
            indexes[i] += 1
            (i+1).upTo(indexes.count - 1) { j in
                indexes[j] = indexes[i]
            }
        }
        return combinations
    }
    
    /**
    Returns all of the combinations in the array of the given length
    
    - parameter length:
    - returns: Combinations
    */
    func combination (_ length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        }
        var indexes: [Int] = (0...(length-1)).toArray()
        var combinations: [[Element]] = []
        let offset = self.count - indexes.count
        while true {
            var combination: [Element] = []
            for index in indexes {
                combination.append(self[index])
            }
            combinations.append(combination)
            var i = indexes.count - 1
            while i >= 0 && indexes[i] == i + offset {
                i -= 1
            }
            if i < 0 {
                break
            }
            i += 1
            let start = indexes[i-1] + 1
            for j in (i-1)..<indexes.count {
                indexes[j] = start + j - i + 1
            }
        }
        return combinations
    }
    
    /**
    Returns all of the permutations of this array of a given length, allowing repeats
    
    - parameter length: The length of each permutations
    :returns All of the permutations of this array of a given length, allowing repeats
    */
    func repeatedPermutation(_ length: Int) -> [[Element]] {
        if length < 1 {
            return []
        }
        var permutationIndexes: [[Int]] = []
        permutationIndexes.repeatedPermutationHelper([], length: length, arrayLength: self.count, permutationIndexes: &permutationIndexes)
        return permutationIndexes.map({ $0.map({ i in self[i] }) })
    }
    
    fileprivate func repeatedPermutationHelper(_ seed: [Int], length: Int, arrayLength: Int, permutationIndexes: inout [[Int]]) {
        if seed.count == length {
            permutationIndexes.append(seed)
            return
        }
        for i in (0..<arrayLength) {
            var newSeed: [Int] = seed
            newSeed.append(i)
            self.repeatedPermutationHelper(newSeed, length: length, arrayLength: arrayLength, permutationIndexes: &permutationIndexes)
        }
    }
    
    /**
    Returns the number of elements which meet the condition
    - parameter test: Function to call for each element
    - returns: the number of elements meeting the condition
    */
    func countWhere (_ test: (Element) -> Bool) -> Int {
        
        var result = 0
        
        for item in self {
            if test(item) {
                result += 1
            }
        }
        
        return result
    }
    
    func eachIndex (_ call: @escaping (Int) -> ()) -> () {
        (0...(self.count-1)).forEach({ call($0) })
    }
    
    /**
    Returns a transposed version of the array, where the object at array[i][j] goes to array[j][i].
    The array must have two or more dimensions.
    If it's a jagged array that has empty spaces between elements in the transposition, those empty spaces are "removed" and the element on the right side of the empty space gets squashed next to the element on the left.
    :return: A transposed version of the array, where the object at array[i][j] goes to array[j][i]
    */
    func transposition (_ array: [[Element]]) -> [[Element]] { //<U: AnyObject where Element == [U]> () -> [[U]] {
        let maxWidth: Int = array.map({ $0.count }).max()
        var transposition = [[Element]](repeating: [], count: maxWidth)
        
        (0...(maxWidth-1)).forEach { i in
            array.eachIndex { j in
                if array[j].count > i {
                    transposition[i].append(array[j][i])
                }
            }
        }
        return transposition
    }
    
    /**
    Replaces each element in the array with object. I.e., it keeps the length the same but makes the element at every index be object
    
    - parameter object: The object to replace each element with
    */
    mutating func fill (_ object: Element) -> () {
        (0...(self.count-1)).forEach { i in
            self[i] = object
        }
    }
    
    /**
    Joins the array elements with a separator.
    - parameter separator:
    :return: Joined object if self is not empty and its elements are instances of C, nil otherwise
    */
    func implode <C: RangeReplaceableCollection> (_ separator: C) -> C? {
        if Element.self is C.Type {
            if let joined = unsafeBitCast(self, to: [C].self).joined(separator: separator) as? C {
                return joined
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    
    /**
    Creates an array with values generated by running each value of self
    through the mapFunction and discarding nil return values.
    
    - parameter mapFunction:
    - returns: Mapped array
    */
    func mapFilter <V> (mapFunction map: (Element) -> (V)?) -> [V] {
        
        var mapped = [V]()
        
        each { (value: Element) -> Void in
            if let mappedValue = map(value) {
                mapped.append(mappedValue)
            }
        }
        
        return mapped
        
    }
    
    /**
    Creates an array with values and an accumulated result by running accumulated result
    and each value of self through the mapFunction.
    
    - parameter initial: Initial value for accumulator
    - parameter mapFunction:
    - returns: Accumulated value and mapped array
    */
    func mapAccum <U, V> (_ initial: U, mapFunction map: (U, Element) -> (U, V)) -> (U, [V]) {
        var mapped = [V]()
        var acc = initial
        
        each { (value: Element) -> Void in
            let (mappedAcc, mappedValue) = map(acc, value)
            acc = mappedAcc
            mapped.append(mappedValue)
        }
        
        return (acc, mapped)
    }
    
    /**
    self.reduce with initial value self.first()
    */
    func reduce (_ combine: (Element, Element) -> Element) -> Element? {
        if let firstElement = first {
            return skip(1).reduce(firstElement, combine)
        }
        
        return nil
    }
    
    /**
    self.reduce from right to left
    */
    @available(*, unavailable, message: "use 'reverse().reduce' instead") func reduceRight <U> (_ initial: U, combine: (U, Element) -> U) -> U {
        return reversed().reduce(initial, combine)
    }
    
    /**
    self.reduceRight with initial value self.last()
    */
    @available(*, unavailable, message: "use 'reverse().reduce' instead") func reduceRight (_ combine: (Element, Element) -> Element) -> Element? {
        return reversed().reduce(combine)
    }
    
    /**
    Creates an array with the elements at the specified indexes.
    
    - parameter indexes: Indexes of the elements to get
    - returns: Array with the elements at indexes
    */
    func at (_ indexes: Int...) -> Array {
        return indexes.map { self.get($0)! }
    }
    
    /**
    Converts the array to a dictionary with the keys supplied via the keySelector.
    
    - parameter keySelector:
    - returns: A dictionary
    */
    func toDictionary <U> (_ keySelector:(Element) -> U) -> [U: Element] {
        var result: [U: Element] = [:]
        for item in self {
            result[keySelector(item)] = item
        }
        
        return result
    }
    
    /**
    Converts the array to a dictionary with keys and values supplied via the transform function.
    
    - parameter transform:
    - returns: A dictionary
    */
    func toDictionary <K, V> (_ transform: (Element) -> (key: K, value: V)?) -> [K: V] {
        var result: [K: V] = [:]
        for item in self {
            if let entry = transform(item) {
                result[entry.key] = entry.value
            }
        }
        
        return result
    }
    
    /**
    Flattens a nested Array self to an array of OutType objects.
    
    - returns: Flattened array
    */
    func flatten <OutType> () -> [OutType] {
        var result = [OutType]()
        let mirror = Mirror(reflecting: self)
        if let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children) {
            
            for (_, value) in mirrorChildrenCollection {
                result += Array.bridgeObjCObject(value) as [OutType]
            }
            
        }
        
        return result
    }
    
    /**
    *  Converts, if possible, and flattens an object from its Objective-C
    *  representation to the Swift one.
    *  @param object Object to convert
    *  @returns Flattenend array of converted values
    */
    internal static func bridgeObjCObject <T, S> (_ object: S) -> [T] {
        var result = [T]()
        let reflection = Mirror(reflecting: object)
        let mirrorChildrenCollection = AnyRandomAccessCollection(reflection.children)
        
        //  object has an Objective-C type
        if let obj = object as? T {
            //  object has type T
            result.append(obj)
        } else if reflection.subjectType == NSArray.self {
            
            //  If it is an NSArray, flattening will produce the expected result
            if let array = object as? NSArray {
                result += (array as NSArray).flatten()
            } else if let bridged = mirrorChildrenCollection as? T {
                result.append(bridged)
            }
            
        } else if object is Array<T> {
            //  object is a native Swift array
            
            //  recursively convert each item
            for (_, value) in mirrorChildrenCollection! {
                result += Array.bridgeObjCObject(value)
            }
            
        }
        
        return result
    }

    
    /**
    Flattens a nested Array self to an array of AnyObject.
    
    - returns: Flattened array
    */
    func flattenAny () -> [AnyObject] {
        var result = [AnyObject]()
        
        for item in self {
            if let array = item as? NSArray {
                result += array.flattenAny()
            } else if let object = item as? NSObject {
                result.append(object)
            }
        }
        
        return result
    }
    
    /**
    Sorts the array according to the given comparison function.
    
    - parameter isOrderedBefore: Comparison function.
    - returns: An array that is sorted according to the given function
    */
    @available(*, unavailable, message: "use 'sort' instead") func sortBy (_ isOrderedBefore: (Element, Element) -> Bool) -> [Element] {
        return sorted(by: isOrderedBefore)
    }
    
    /**
    Calls the passed block for each element in the array, either n times or infinitely, if n isn't specified
    - parameter n: the number of times to cycle through
    - parameter block: the block to run for each element in each cycle
    */
    func cycle (_ n: Int? = nil, block: (Element) -> ()) {
        var cyclesRun = 0
        while true {
            if let n = n {
                if cyclesRun >= n {
                    break
                }
            }
            for item in self {
                block(item)
            }
            cyclesRun += 1
        }
    }
    
    /**
    Runs a binary search to find the smallest element for which the block evaluates to true
    The block should return true for all items in the array above a certain point and false for all items below a certain point
    If that point is beyond the furthest item in the array, it returns nil
    See http://ruby-doc.org/core-2.2.0/Array.html#method-i-bsearch regarding find-minimum mode for more
    - parameter block: the block to run each time
    - returns: the min element, or nil if there are no items for which the block returns true
    */
    func bSearch (_ block: (Element) -> (Bool)) -> Element? {
        if count == 0 {
            return nil
        }
        
        var low = 0
        var high = count - 1
        while low <= high {
            let mid = low + (high - low) / 2
            if block(self[mid]) {
                if mid == 0 || !block(self[mid - 1]) {
                    return self[mid]
                } else {
                    high = mid
                }
            } else {
                low = mid + 1
            }
        }
        
        return nil
    }
    
    /**
    Runs a binary search to find some element for which the block returns 0.
    The block should return a negative number if the current value is before the target in the array, 0 if it's the target, and a positive number if it's after the target
    The Spaceship operator is a perfect fit for this operation, e.g. if you want to find the object with a specific date and name property, you could keep the array sorted by date first, then name, and use this call:
    let match = bSearch {  [targetDate, targetName] <=> [$0.date, $0.name] }
    See http://ruby-doc.org/core-2.2.0/Array.html#method-i-bsearch regarding find-any mode for more
    
    - parameter block: the block to run each time
    - returns: an item (there could be multiple matches) for which the block returns true
    */
    /*func bSearch (block: (Element) -> (Int)) -> Element? {
    let match = bSearch { item in
    block(item) >= 0
    }
    if let match = match {
    return block(match) == 0 ? match : nil
    } else {
    return nil
    }
    }*/
    
    /**
    Sorts the array by the value returned from the block, in ascending order
    - parameter block: the block to use to sort by
    - returns: an array sorted by that block, in ascending order
    */
    func sortUsing <U:Comparable> (_ block: ((Element) -> U)) -> [Element] {
        return self.sorted(by: { block($0.0) < block($0.1) })
    }
    
    /**
    Removes the last element from self and returns it.
    - returns: The removed element
    */
    mutating func pop () -> Element? {
        
        if self.isEmpty {
            return nil
        }
        
        return removeLast()
        
    }
    
    /**
    Same as append.
    
    - parameter newElement: Element to append
    */
    mutating func push (_ newElement: Element) {
        return append(newElement)
    }
    
    /**
    Returns the first element of self and removes it from the array.
    
    - returns: The removed element
    */
    mutating func shift () -> Element? {
        
        if self.isEmpty {
            return nil
        }
        
        return self.remove(at: 0)
        
    }
    
    /**
    Prepends an object to the array.
    
    - parameter newElement: Object to prepend
    */
    mutating func unshift (_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    /**
    Inserts an array at a given index in self.
    
    - parameter newArray: Array to insert
    - parameter atIndex: Where to insert the array
    */
    mutating func insert (_ newArray: Array, atIndex: Int) {
        self = take(atIndex) + newArray + skip(atIndex)
    }
    
    /**
    Deletes all the items in self that are equal to element.
    
    - parameter element: Element to remove
    */
    mutating func remove<T: Equatable>(_ object: T) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? T {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
    
    /**
    Constructs an array containing the values in the given range.
    
    - parameter range:
    - returns: Array of values
    */
    /* Swift 3.0 removed unknown
    @available(*, unavailable, message: "use the '[U](range)' constructor") func range <U: Comparable> (_ range: Range<U>) -> [U] {
        return [U](range)
    }
    */
    
    /**
    Returns the subarray in the given range.
    
    - parameter range: Range of the subarray elements
    - returns: Subarray or nil if the index is out of bounds
    */
    subscript (rangeAsArray rangeAsArray: Range<Int>) -> Array {
        //  Fix out of bounds indexes
        let start = Swift.max(0, rangeAsArray.lowerBound)
        let end = Swift.min(rangeAsArray.upperBound, count)
        
        if start > end {
            return []
        }
        
        return Array(self[Range(start..<end)] as ArraySlice<Element>)
    }
    
    /**
    Returns a subarray whose items are in the given interval in self.
    
    - parameter interval: Interval of indexes of the subarray elements
    - returns: Subarray or nil if the index is out of bounds
    */
    subscript (interval: Range<Int>) -> Array {
        return self[rangeAsArray: Range(interval.lowerBound...(interval.upperBound-1))]
    }
    
    /**
    Returns a subarray whose items are in the given interval in self.
    
    - parameter interval: Interval of indexes of the subarray elements
    - returns: Subarray or nil if the index is out of bounds
    */
    subscript (interval: ClosedRange<Int>) -> Array {
        return self[rangeAsArray: Range(interval.lowerBound...interval.upperBound)]
    }
    
    /**
    Creates an array with the elements at indexes in the given list of integers.
    
    - parameter first: First index
    - parameter second: Second index
    - parameter rest: Rest of indexes
    - returns: Array with the items at the specified indexes
    */
    subscript (first: Int, second: Int, rest: Int...) -> Array {
        let indexes = [first, second] + rest
        return indexes.map { self[$0] }
    }
}

/**
Remove an element from the array
*/
public func - <T: Equatable> (first: Array<T>, second: T) -> Array<T> {
    return first - [second]
}

/**
Difference operator
*/
public func - <T: Equatable> (first: Array<T>, second: Array<T>) -> Array<T> {
    return first.difference(second)
}

/**
Intersection operator
*/
public func & <T: Equatable> (first: Array<T>, second: Array<T>) -> Array<T> {
    return first.intersection(second)
}

/**
Union operator
*/
public func | <T: Equatable> (first: Array<T>, second: Array<T>) -> Array<T> {
    return first.union(second)
}
/**
Array duplication.

- parameter array: Array to duplicate
- parameter n: How many times the array must be repeated
- returns: Array of repeated values
*/
public func * <ItemType> (array: Array<ItemType>, n: Int) -> Array<ItemType> {
    var result = Array<ItemType>()
    
    n.times {
        result += array
    }
    
    return result
}

extension Collection where Iterator.Element == Int {
    var indexSet: IndexSet {
        let result = NSMutableIndexSet()
        for index in self {
            result.add(index)
        }
        return result as IndexSet
    }
}
