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
    private var _comments: String!
    private var _postPriority: AnyObject!
    
    
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
    
    var postRef: Firebase {
        return _postRef
    }
    
    var comments: String {
        if _comments == nil {
            _comments = "0"
        }
        return _comments
    }
    
    var postPriority: AnyObject {
        return _postPriority
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postPriority: AnyObject, postKey: String, dictionary: Dictionary<String,AnyObject>) {
        self._postKey = postKey
        self._postPriority = postPriority
        
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
        
        if let commentsDict = dictionary["comments"] as? Dictionary<String,AnyObject> {
            self._comments = "\(commentsDict.count)"
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    
}