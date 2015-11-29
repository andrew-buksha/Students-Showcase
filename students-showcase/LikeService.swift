//
//  LikeService.swift
//  Showcase
//
//  Created by Андрей Букша on 29.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class LikeService {
    
    static let ls = LikeService()
    
    func adjustLikes(var likes: Int, addLike: Bool, ref: Firebase) {
        if addLike {
            likes = likes + 1
        } else {
            likes = likes - 1
        }
        
        ref.childByAppendingPath("likes").setValue(likes)
    }
    
    func observeSingleEvent(likeRef: Firebase, likeImg: UIImageView) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                likeImg.image = UIImage(named: "heart-empty")
            } else {
                likeImg.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(likeRef: Firebase, likeImg: UIImageView, var likes: Int, ref: Firebase) {
            likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
            likeImg.image = UIImage(named: "heart-full")
            self.adjustLikes(likes, addLike: true, ref: ref)
            likeRef.setValue(true)
            } else {
            likeImg.image = UIImage(named: "heart-empty")
            self.adjustLikes(likes, addLike: false, ref: ref)
            likeRef.removeValue()
            }
            })
    }
    
}
