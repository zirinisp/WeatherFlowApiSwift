//
//  Session.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//


public class Session {
    static var TokenKey = "wf_token"

    public private (set) var status: Status?
    public private (set) var token: String?
    public private (set) var user: User?
    
    convenience public init(dictionary: [String : AnyObject]) {
        self.init()
        self.status = (dictionary[Status.Key] as? Status)
        self.token = (dictionary[Session.TokenKey] as? String)
        self.user = (dictionary[User.Key] as? User)
    }
    
    public var description: String {
        let description: String = "\(self.status) \(self.token) \(self.user)"
        return "<\(self.dynamicType): \(self), \(description)>"
    }

}
