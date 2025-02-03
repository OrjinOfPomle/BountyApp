//
//  UserService.swift
//  Bounty
//
//  Created by Keleabe M. on 7/24/20.
//  Copyright © 2020 FireflyGlobe. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let UserService = _UserService()

final class _UserService{
    var user = User()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration? = nil
    
    func getCurrentUser(){
        guard let authUser = auth.currentUser else {return}
        
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else {return}
            self.user = User.init(data : data)
            print(self.user)
            
        })
        
    }
}

