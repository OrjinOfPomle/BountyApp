//
//  User.swift
//  Bounty
//
//  Created by Keleabe M. on 7/20/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//


import Foundation
import FirebaseFirestore

struct User {
    var UserName : String
    var email : String
    var Image : String
    var StripeId : String
    var id : String
    
    init(data :[String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.UserName = data["name"] as? String ?? ""
        self.Image = data["image"] as? String ?? "" // replace with a genaric image
        self.StripeId = data["stripeId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
    
    init(id:String = "", email: String = "", Image : String = "", StripeId : String = "", UserName: String = ""){
        self.UserName = UserName
        self.email = email
        self.Image = Image
        self.StripeId = StripeId
        self.id = id
    }
    
    static func modelToData(user : User) -> [String : Any]{
        let data : [String : Any] = [
            "UserName" : user.UserName,
            "email" : user.email,
            "Image" : user.Image,
            "StripeId" : user.StripeId,
            "id" : user.id
        ]
        return data
    }
    
    
}
