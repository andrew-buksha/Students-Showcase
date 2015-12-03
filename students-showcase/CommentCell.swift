//
//  CommentCell.swift
//  students-showcase
//
//  Created by Андрей Букша on 27.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentTxt: UILabel!
    @IBOutlet weak var commentImg: UIImageView!
    
    var comment: Comment!
    var request: Request?
    var likeRef: Firebase!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        commentImg.clipsToBounds = true
    }
    
    func configureCell(comment: Comment, img: UIImage?, profileImage: UIImage?) {
        
        self.comment = comment
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath("comments").childByAppendingPath(comment.commentKey)
        
        self.profileName.text = comment.username
        self.likesCount.text = "\(comment.postLikes)"
        self.commentTxt.text = comment.postDescription
        
        if comment.imageUrl != nil {
            if img != nil {
                self.commentImg.image = img
            } else {
                request = Alamofire.request(.GET, comment.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.commentImg.image = img
                        CommentsVC.commentCache.setObject(img, forKey: self.comment.imageUrl!)
                    }
                })
            }
        } else {
            commentImg.hidden = true
        }
        
        if comment.userImg != nil {
            if profileImage != nil {
                self.profileImg.image = profileImage
            } else {
                request = Alamofire.request(.GET, comment.userImg!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let profileImage = UIImage(data: data!)!
                        self.profileImg.image = profileImage
                        CommentsVC.commentCache.setObject(profileImage, forKey: self.comment.userImg!)
                    }
                })
            }
        }
        
        LikeService.ls.observeSingleEvent(likeRef, likeImg: self.likeImg)
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        LikeService.ls.likeTapped(likeRef, likeImg: self.likeImg, likes: comment.postLikes, ref: comment.commentRef)
    }
    

}
