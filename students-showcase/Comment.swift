//
//  Comment.swift
//  Showcase
//
//  Created by Андрей Букша on 28.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import Foundation
import Firebase

class Comment: Post {
    
    private var _commentKey: String!
    private var _commentRef: Firebase!
    private var _REF_COMMENTS: Firebase!
    
    var commentKey: String {
        return _commentKey
    }
    
    var commentRef: Firebase {
        return _commentRef
    }
    
    var REF_COMMENTS: Firebase {
        return _REF_COMMENTS
    }
    
    convenience init(commentKey: String, postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self.init(postPriority: "", postKey: postKey, dictionary: dictionary)
        self._commentKey = commentKey
        
        self._commentRef = DataService.ds.REF_POSTS.childByAppendingPath(postKey).childByAppendingPath("comments").childByAppendingPath(self._commentKey)
        self._REF_COMMENTS = DataService.ds.REF_POSTS.childByAppendingPath(postKey).childByAppendingPath("comments")
    }
}