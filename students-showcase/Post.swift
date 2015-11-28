//
//  Post.swift
//  students-showcase
//
//  Created by Андрей Букша on 23.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _postLikes: Int!
    private var _username: String!
    private var _userImg: String?
    private var _postKey: String!
    private var _postRef: Firebase!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var username: String {
        return _username
    }
    
    var userImg: String? {
        return _userImg
    }
    
    var postLikes: Int {
        return _postLikes
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String,AnyObject>) {
        self._postKey = postKey
        
        if let postLikes = dictionary["likes"] as? Int {
            self._postLikes = postLikes
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let author = dictionary["username"] as? String {
            self._username = author
        }
        
        if let authorImg = dictionary["profileImg"] as? String {
            self._userImg = authorImg
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _postLikes = _postLikes + 1
        } else {
            _postLikes = _postLikes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_postLikes)
    }
    
    
}