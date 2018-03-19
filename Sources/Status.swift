//
//  Status.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

public struct Status: Codable {
    public let statusCode: Int
    public let statusMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
    
    public var description: String {
        let description: String = "\(Int(self.statusCode)) \(self.statusMessage ?? "No Status")"
        return "<\(type(of: self)): \(self), \(description)>"
    }

}
