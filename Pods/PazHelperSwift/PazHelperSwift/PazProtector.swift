//
//  PazProtector.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 14/05/2015.
//  Copyright (c) 2015 paz-labs. All rights reserved.
//

import Foundation

public class PazReadWriteLock {
    public private (set) lazy var queue: DispatchQueue = DispatchQueue(label: self.lockName, attributes: .concurrent)
    
    public init(lockName: String) {
        self.lockName = lockName
    }
    
    public convenience init(randomLockName: String) {
        let lockName = PazReadWriteLock.RandomLockName(randomLockName)
        self.init(lockName: lockName)
    }
    
    class func RandomLockName(_ prefix: String) -> String {
        let random = Int(arc4random_uniform(10000))
        return "\(prefix).\(random)"
    }
    
    public private (set) var lockName: String
    
    public func withReadLock(closure: @escaping () -> Void) {
        self.queue.sync {
            closure()
        }
    }
    
    public func withWriteLock(closure: @escaping () -> Void) {
    //  dispatch_barrier_sync(queue) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) {
            closure()
        }
    }
}

public func UniqueNameWith(_ prefix: String) -> String {
    let random = Int(arc4random_uniform(10000))
    return "\(prefix).\(random)"
}

/*
 * A convenience class to wrap a locked object. All access to the object must go through
 * blocks passed to this object.
 */
public class PazProtector<T> {
    private let lock : PazReadWriteLock
    private var item: T
    
    public init(name: String, item: T) {
        self.lock = PazReadWriteLock(lockName: name)
        self.item = item
    }
    
    public convenience init(item: T) {
        self.init(name: UniqueNameWith("PazProtector"), item: item)
    }
    
    public func withReadLock(block: @escaping (T) -> Void) {
        lock.withReadLock() { [weak self] in
            guard let strongSelf = self else {
                return
            }
            block(strongSelf.item)
        }
    }
    
    public func withWriteLock(block: @escaping (inout T) -> Void) {
        lock.withWriteLock() { [weak self] in
            guard let strongSelf = self else {
                return
            }
            block(&strongSelf.item)
        }
    }
}

public class PazProtectedDictionary<S: Hashable, T>: PazReadWriteLock {
    public override init(lockName: String) {
        self.item = Dictionary<S, T>()
        super.init(lockName: lockName)
    }
    
    public convenience init(_ randomLockName: String) {
        let lockName = PazProtectedDictionary.RandomLockName(randomLockName)
        self.init(lockName: lockName)
    }
    
    private var item: Dictionary<S, T>
    
    public var unprotectedItem: Dictionary<S, T> {
        return self.item
    }
    
    public subscript(key: S) -> T? {
        get {
            var result: T?
            self.queue.sync { [weak self] in
                result = self?.item[key]
            }
            return result
            
        }
        set(object) {
            //            dispatch_barrier_sync(queue) {
            self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
                self?.item[key] = object
            }
        }
    }
    
    /// Deletes all object of the dictionary
    public func reset() {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = Dictionary<S, T>()
        }
    }
    
    /// Rerplaces current dictionary
    public func setDictionary(_ newDictinoary: Dictionary<S, T>) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = newDictinoary
        }
    }
}


public class PazProtectedArray<T>: PazReadWriteLock {
    public override init(lockName: String) {
        self.item = Array<T>()
        super.init(lockName: lockName)
    }
    
    public convenience init(randomLockName: String) {
        let lockName = PazProtectedArray.RandomLockName(randomLockName)
        self.init(lockName: lockName)
    }
    
    private var item: Array<T>
    
    public var unprotectedItem: Array<T> {
        return self.item
    }
    
    public var copiedItem: Array<T>? {
        var result: Array<T>?
        self.queue.sync { [weak self] in
            if let strongSelf = self {
                result = Array<T>(strongSelf.item)
            }
        }
        return result
    }
    
    public subscript(index: Int) -> T? {
        get {
            var result: T?
            self.queue.sync { [weak self] in
                result = self?.item[index]
            }
            return result
            
        }
        set(object) {
            self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
                if let letObject = object {
                    self?.item[index] = letObject
                } else {
                    self?.item.remove(at: index)
                }
            }
        }
    }

    public func append(_ item: T) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item.append(item)
        }
    }

    public func remove<E>(_ item: E) -> Bool where E: Equatable {
        var result = false
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            result = self?.item.remove(item) ?? false
        }
        return result
    }

    public var count: Int {
        var result: Int = 0
        self.queue.sync { [weak self] in
            result = self?.item.count ?? 0
        }
        return result
    }
    
    /// Deletes all object of the dictionary
    public func reset() {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = Array<T>()
        }
    }
    
    /// Rerplaces current dictionary
    public func setArray(_ newArray: Array<T>) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = newArray
        }
    }
}


public class PazProtectedSet<T: Hashable>: Collection {
    public init(lockName: String) {
        self.lockName = lockName
        self.item = Set<T>()
    }
    
    public convenience init(_ randomLockName: String) {
        let lockName = PazProtectedSet.RandomLockName(randomLockName)
        self.init(lockName: lockName)
    }
    
    private class func RandomLockName(_ prefix: String) -> String {
        let random = Int(arc4random_uniform(10000))
        return "\(prefix).\(random)"
    }
    
    private lazy var queue: DispatchQueue = DispatchQueue(label: self.lockName, attributes: .concurrent)
    public private (set) var lockName: String
    private var item: Set<T>
    
    public var unprotectedItem: Set<T> {
        return self.item
    }
    
    /// Insert a member into the set.
    public func insert(_ member: T) {
        let _ = self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item.insert(member)
        }
    }
    
    /// Remove the member from the set and return it if it was present.
    public func remove(_ member: T) -> T? {
        var itemToReturn: T?
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            itemToReturn = self?.item.remove(member)
        }
        return itemToReturn
    }
    
    /// Remove the member referenced by the given index.
    public func removeAtIndex(_ index: SetIndex<T>) {
        let  _ = self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item.remove(at: index)
        }
    }
    
    /// Erase all the elements.  If `keepCapacity` is `true`, `capacity`
    /// will not decrease.
    public func removeAll(keepCapacity: Bool) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item.removeAll(keepingCapacity: keepCapacity)
        }
    }
    
    /// Remove a member from the set and return it. Requires: `count > 0`.
    public func removeFirst() -> T {
        var itemToReturn: T?
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            itemToReturn = self?.item.removeFirst()
        }
        return itemToReturn!
    }
    
    public var count: Int {
        var count = 0
        self.queue.sync { [weak self] in
            count = self?.item.count ?? 0
        }
        return count
    }
    
    public subscript (position: SetIndex<T>) -> T {
        get {
            var result: T?
            self.queue.sync { [weak self] in
                result = self?.item[position]
            }
            return result!
        }
    }

    /// Returns `true` iff the `Interval` contains `x`
    public func contains(x: T) -> Bool {
        var result = false
        self.queue.sync { [weak self] in
            result = self?.item.contains(x) ?? false
        }
        return result
    }
    
    /// Deletes all object of the dictionary
    public func reset() {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = Set<T>()
        }
    }
    
    /// Rerplaces current dictionary
    public func setNewSet(_ newSet: Set<T>) {
        self.queue.sync(flags: DispatchWorkItemFlags.barrier) { [weak self] in
            self?.item = newSet
        }
    }
    /* Swift 3.0 Removed
    public func generate() -> SetGenerator<T> {
        var result: SetGenerator<T>?
        self.queue.sync { [weak self] in
            result = self.item.generate()
        }
        return result!
        
    }*/
    
    /// The position of the first element in a non-empty set.
    ///
    /// This is identical to `endIndex` in an empty set.
    ///
    /// Complexity: amortized O(1) if `self` does not wrap a bridged
    /// `NSSet`, O(N) otherwise.
    public var startIndex: SetIndex<T> {
        var result: SetIndex<T>?
        self.queue.sync { [weak self] in
            result = self?.item.startIndex
        }
        return result!
        
    }
    
    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always
    /// reachable from `startIndex` by zero or more applications of
    /// `successor()`.
    ///
    /// Complexity: amortized O(1) if `self` does not wrap a bridged
    /// `NSSet`, O(N) otherwise.
    public var endIndex: SetIndex<T> {
        var result: SetIndex<T>?
        self.queue.sync { [weak self] in
            result = self?.item.endIndex
        }
        return result!
    }
    
    public func index(after i: SetIndex<T>) -> SetIndex<T> {
        var result: SetIndex<T>?
        self.queue.sync { [weak self] in
            result = self?.item.index(after: i)
        }
        return result!
    }
}
