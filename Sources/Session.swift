//
//  Session.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//


open class Session {
    static var TokenKey = "wf_token"

    open fileprivate (set) var status: Status?
    open fileprivate (set) var token: String?
    open fileprivate (set) var user: User?
    
    convenience public init(dictionary: [String : Any]) {
        self.init()
        self.status = (dictionary[Status.Key] as? Status)
        self.token = (dictionary[Session.TokenKey] as? String)
        self.user = (dictionary[User.Key] as? User)
    }
    
    open var description: String {
        let description: String = "\(self.status) \(self.token) \(self.user)"
        return "<\(type(of: self)): \(self), \(description)>"
    }

}
