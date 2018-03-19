//
//  User.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

import Foundation

public struct User: Codable {
    public let accessLevel: Int?
    public let activeProfileID: String?
    public let approxLat: Double?
    public let approxLon: Double?
    public let canAdsToggle: String?
    public let defaultAdsToggleState: String?
    public let isApplePurchase: String?
    public let isComp: String?
    public let isOffline: String?
    public let memberLevel: Int?
    public let memberLevelName: String?
    public let nonTrialMemberLevel: Int?
    public let nonTrialMemberLevelName: String?
    public let refreshReceipt: Bool?
    public let showAds: String?
    public let showAdsToggle: String?
    public let wfUsername: String?
    
    enum CodingKeys: String, CodingKey {
        case accessLevel = "access_level"
        case activeProfileID = "active_profile_id"
        case approxLat = "approx_lat"
        case approxLon = "approx_lon"
        case canAdsToggle = "can_ads_toggle"
        case defaultAdsToggleState = "default_ads_toggle_state"
        case isApplePurchase = "is_apple_purchase"
        case isComp = "is_comp"
        case isOffline = "is_offline"
        case memberLevel = "member_level"
        case memberLevelName = "member_level_name"
        case nonTrialMemberLevel = "non_trial_member_level"
        case nonTrialMemberLevelName = "non_trial_member_level_name"
        case refreshReceipt = "refresh_receipt"
        case showAds = "show_ads"
        case showAdsToggle = "show_ads_toggle"
        case wfUsername = "wf_username"
    }
}
