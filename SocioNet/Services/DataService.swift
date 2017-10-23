//
//  DataService.swift
//  SocioNet
//
//  Created by Nishant on 23/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import Foundation
import Firebase

// Constant to store reference to Firebase Database.
let DB_BASE = Database.database().reference()

class DataService {
    
    // Create object for Singleton class.
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
