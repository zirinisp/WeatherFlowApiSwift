//
//  NotificationManager.swift
//  PazHelperSwift
//
//  Created by Pantelis Zirinis on 07/10/2014.
//  Copyright (c) 2014 paz-labs. All rights reserved.
//
//  http://moreindirection.blogspot.gr/2014/08/nsnotificationcenter-swift-and-blocks.html

import Foundation

struct PazObserverToken: Equatable {
    let token : AnyObject
    let name : Notification.Name
}

func ==(lhs: PazObserverToken, rhs: PazObserverToken) -> Bool {
    return lhs.name == rhs.name
}

public class PazNotificationManager {
    
    public init () {
    
    }
    
    private var observerTokens: [PazObserverToken] = []
    
    deinit {
        self.deregisterAll()
    }
    
    // MARK: - Observer Registrations
    public func registerObserver(_ name: Notification.Name!, block: @escaping ((Notification!) -> Void)) {
        let newToken = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { (note) in
            block(note)
        }
        self.observerTokens.append(PazObserverToken(token: newToken, name: name))
    }
    
    public func registerObserver(_ name: Notification.Name!, forObject object: AnyObject!, block: @escaping ((Notification!) -> Void)) {
        let newToken = NotificationCenter.default.addObserver(forName: name, object: object, queue: nil) {note in
            block(note)
            ()
        }
        
        self.observerTokens.append(PazObserverToken(token: newToken, name: name))
    }
    
    public func registerObservers(_ names: [Notification.Name], block: @escaping ((Notification!) -> Void)) {
        for name in names {
            self.registerObserver(name, block: block)
        }
    }

    public func registerObservers(_ names: [Notification.Name], forObject object: AnyObject!, block: @escaping ((Notification!) -> Void)) {
        for name in names {
            self.registerObserver(name, forObject: object, block: block)
        }
    }

    public func registerObservers(_ observerDictionary: [Notification.Name: AnyObject], block: @escaping ((Notification!) -> Void)) {
        for (name, object) in observerDictionary {
            self.registerObserver(name, forObject: object, block: block)
        }
    }
    
    // MARK: - Observer Deregistrations
    public func deregisterAll() {
        for token in observerTokens {
            NotificationCenter.default.removeObserver(token.token)
        }
        
        self.observerTokens = []
    }
    
    public func deregisterAllObserversWithName(_ name: Notification.Name!) {
        var tokensLeft = [PazObserverToken]()
        for token in observerTokens {
            if token.name == name {
                NotificationCenter.default.removeObserver(token.token)
            } else {
                tokensLeft.append(token)
            }
        }

        self.observerTokens = tokensLeft
    }

    public func deregisterAllObserversWithNames(_ names: [Notification.Name]) {
        for name in names {
            self.deregisterAllObserversWithName(name)
        }
    }

    // MARK: - Post Helpers
    public class func postNotificationName(_ name: Notification.Name, object: AnyObject?) {
        NotificationCenter.default.post(name: name, object: object)
    }
    
    public class func postNotificationName(_ name: Notification.Name, object: AnyObject?, userInfo: [NSObject: AnyObject]?) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
}

