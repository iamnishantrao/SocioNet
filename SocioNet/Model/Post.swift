//
//  Post.swift
//  SocioNet
//
//  Created by Nishant on 24/10/17.
//  Copyright © 2017 rao. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(caption: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        // Set data received from Firabase.
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        // Reference to current post.
        self._postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(liked: Bool) {
        if liked {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        // Set number of likes for a particular post using database reference to particular reference.
        _postRef.child("likes").setValue(_likes)
    }
}
