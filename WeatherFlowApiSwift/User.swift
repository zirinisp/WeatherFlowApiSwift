//
//  User.swift
//  WeatherFlowApiSwift
//
//  Created by Pantelis Zirinis on 25/12/2015.
//  Copyright © 2015 Pantelis Zirinis. All rights reserved.
//

public class User {
    static var Key = "wf_user"
    
    var wf_username: String?
    var email: String?
    var zip: String?
    var active_profile_id: Int?
    var access_level: Int?
    var trial_end_date: String?
    var member_level_name: String?
    var show_ads: Bool?
    var show_ads_toggle: Bool?
    var can_ads_toggle: Bool?
    var member_id: Int?
    var member_level: Int?
    var default_ads_toggle_state: Int? //1,0
    var trial_status: String?
    var trial_message: String?
    var trial_days_left: Int?
    var messages: [AnyObject]?
    var non_trial_member_level: Int?
    var non_trial_member_level_name: String?
    var trialEndDate: NSDate?
    
    convenience public init(dictionary: [NSObject : AnyObject]) {
        self.init()
        wf_username = (dictionary["wf_username"] as? String)
        email = (dictionary["email"] as? String)
        zip = (dictionary["zip"] as? String)
        active_profile_id = (dictionary["active_profile_id"] as? Int)
        access_level = (dictionary["access_level"] as? Int)
        trial_end_date = (dictionary["trial_end_date"] as? String)
        member_level_name = (dictionary["member_level_name"] as? String)
        show_ads = (dictionary["show_ads"] as? Bool)
        show_ads_toggle = (dictionary["show_ads_toggle"] as? Bool)
        can_ads_toggle = (dictionary["can_ads_toggle"] as? Bool)
        member_id = (dictionary["member_id"] as? Int)
        member_level = (dictionary["member_level"] as? Int)
        default_ads_toggle_state = (dictionary["default_ads_toggle_state"] as? Int)
        trial_status = (dictionary["trial_status"] as? String)
        trial_message = (dictionary["trial_message"] as? String)
        trial_days_left = (dictionary["trial_days_left"] as? Int)
        messages = (dictionary["messages"] as? [AnyObject])
        non_trial_member_level = (dictionary["non_trial_member_level"] as? Int)
        non_trial_member_level_name = (dictionary["non_trial_member_level_name"] as? String)
        trialEndDate = (dictionary["trialEndDate"] as? NSDate)
    }
}
