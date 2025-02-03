//
//  Comments.swift
//  Bounty
//
//  Created by Keleabe M. on 6/6/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Comment {
    var UserName : String
    var Image : String
    var Comment : String
    var DonorCount : Int
    var BountyAmount : Int
    var timeStamp : Timestamp
    
    init(data :[String: Any]) {
        self.UserName = data["name"] as? String ?? ""
        self.DonorCount = data["contributorCount"] as? Int ?? 0
        self.Image = data["image"] as? String ?? "" // replace with a genaric image
        self.BountyAmount = data["amount"] as? Int ?? 0
        self.timeStamp = data["expireTime"] as? Timestamp ?? Timestamp()
        self.Comment = data["comment"] as? String ?? "Message not found"
    }
}
