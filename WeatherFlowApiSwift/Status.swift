//
//  Status.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

public class Status: NSObject, NSCoding {
    public convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        if let statusCode = dictionary[Status.CodeKey] as? Int, statusMessage = dictionary[Status.MessageKey] as? String {
            self.statusCode = statusCode
            self.statusMessage = statusMessage
        } else {
            return nil
        }
        
    }
    
    public private (set) var statusCode: Int = 0
    public private (set) var statusMessage: String = ""
    
    static var Key: String = "status"
    static var CodeKey: String = "status_code"
    static var MessageKey: String = "status_message"
    
    public override var description: String {
        let description: String = "\(Int(self.statusCode)) \(self.statusMessage)"
        return "<\(self.dynamicType): \(self), \(description)>"
    }
    //===========================================================
    //  Keyed Archiving
    //
    //===========================================================
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeInteger(self.statusCode, forKey: "statusCode")
        encoder.encodeObject(self.statusMessage, forKey: "statusMessage")
    }
    
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        if let statusCode = decoder.decodeObjectForKey("statusCode") as? Int, statusMessage = decoder.decodeObjectForKey("statusMessage") as? String {
            self.statusCode = statusCode
            self.statusMessage = statusMessage
        } else {
            return nil
        }
    }
}