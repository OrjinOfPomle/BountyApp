//
//  Channel.swift
//  Bounty
//
//  Created by Keleabe M. on 6/6/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import Foundation

struct ChannelInfo {
    
    var channelName : String
    var followerCount : Int
    var image : String
    var id : String
    var isActive : Bool
    var Banner : String
    var uId : String
    
    init(data :[String: Any]) {
        self.uId = data["uId"] as? String ?? ""
        self.channelName = data["Name"] as? String ?? ""
        self.followerCount = data["SubsCount"] as? Int ?? 0
        self.image = data["Image"] as? String ?? "" // replace with a genaric image
        self.id = data["Id"] as? String ?? ""
        self.isActive = data["IsActive"] as? Bool ?? true
        self.Banner = data["Banner"] as? String ?? ""
    }
}
