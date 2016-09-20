//
//  Status.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

open class Status: NSObject, NSCoding {
    public convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        if let statusCode = dictionary[Status.CodeKey] as? Int, let statusMessage = dictionary[Status.MessageKey] as? String {
            self.statusCode = statusCode
            self.statusMessage = statusMessage
        } else {
            return nil
        }
        
    }
    
    open fileprivate (set) var statusCode: Int = 0
    open fileprivate (set) var statusMessage: String = ""
    
    static var Key: String = "status"
    static var CodeKey: String = "status_code"
    static var MessageKey: String = "status_message"
    
    open override var description: String {
        let description: String = "\(Int(self.statusCode)) \(self.statusMessage)"
        return "<\(type(of: self)): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(self.statusCode, forKey: "statusCode")
        encoder.encode(self.statusMessage, forKey: "statusMessage")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        if let statusCode = decoder.decodeObject(forKey: "statusCode") as? Int, let statusMessage = decoder.decodeObject(forKey: "statusMessage") as? String {
            self.statusCode = statusCode
            self.statusMessage = statusMessage
        } else {
            return nil
        }
    }
}
