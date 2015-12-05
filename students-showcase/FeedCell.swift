//
//  FeedCell.swift
//  students-showcase
//
//  Created by Андрей Букша on 22.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var showcaseTxt: UITextView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var postRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
        
    }

    func configureCell(post: Post, img: UIImage?, profileImage: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath("posts").childByAppendingPath(post.postKey)
        postRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(post.postKey)
        
        self.showcaseTxt.text = post.postDescription
        self.likesCount.text = "\(post.postLikes)"
        self.profileName.text = post.username
        self.commentsLbl.text = post.comments
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.feedCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        if post.userImg != nil {
            if profileImage != nil {
                self.profileImg.image = profileImage
            } else {
                request = Alamofire.request(.GET, post.userImg!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let profileImage = UIImage(data: data!)!
                        self.profileImg.image = profileImage
                        FeedVC.feedCache.setObject(profileImage, forKey: self.post.userImg!)
                    }
                })
            }
        }
        
        
        postRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.editBtn.hidden = true
                self.deleteBtn.hidden = true
            } else {
                self.editBtn.hidden = false
                self.deleteBtn.hidden = false
            }
        })
        
        LikeService.ls.observeSingleEvent(likeRef, likeImg: self.likeImg)
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        LikeService.ls.likeTapped(likeRef, likeImg: self.likeImg, likes: post.postLikes, ref: post.postRef)
    }

} 
