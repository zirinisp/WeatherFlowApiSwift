//
//  Profile.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//


struct Profile: Codable {
    let activity: String?
    let views: Int?
    let createdBy: String?
    let dateCreated: String?
    let latCenter: Double?
    let latMax: Double?
    let latMin: Double?
    let lonCenter: Double?
    let lonMax: Double?
    let lonMin: Double?
    let myProfile: String?
    let name: String?
    let profileID: Int?
    let favoriteSpots: [FavoriteSpot]?
    
    enum CodingKeys: String, CodingKey {
        case activity = "activity"
        case views = "views"
        case createdBy = "created_by"
        case dateCreated = "date_created"
        case latCenter = "lat_center"
        case latMax = "lat_max"
        case latMin = "lat_min"
        case lonCenter = "lon_center"
        case lonMax = "lon_max"
        case lonMin = "lon_min"
        case myProfile = "my_profile"
        case name = "name"
        case profileID = "profile_id"
        case favoriteSpots = "favorite_spots"
    }
}

struct FavoriteSpot: Codable {
    let typeID: Int
    let favSpotID: Int
    let spotID: Int
    let name: String
    let lat: Double
    let lon: Double
    
    enum CodingKeys: String, CodingKey {
        case typeID = "type_id"
        case favSpotID = "fav_spot_id"
        case spotID = "spot_id"
        case name = "name"
        case lat = "lat"
        case lon = "lon"
    }
}

