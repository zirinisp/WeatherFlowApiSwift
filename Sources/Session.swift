//
//  Session.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

public struct Session: Codable {
    let status: Status?
    let token: String?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case token = "wf_token"
        case user = "wf_user"
    }
    
    var description: String {
        var description: String = ""
        if let status = self.status {
            description += "\(status) "
        } else {
            description += "No Status "
        }
        if let token = self.token {
            description += "\(token) "
        } else {
            description += "No Token "
        }
        if let user = self.user {
            description += "\(user)"
        } else {
            description += "No User"
        }
        return "<\(type(of: self)): \(self), \(description)>"
    }

}
