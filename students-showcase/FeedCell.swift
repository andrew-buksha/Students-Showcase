//
//  FeedCell.swift
//  students-showcase
//
//  Created by Андрей Букша on 22.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var showcaseTxt: UITextView!
    
    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
        
    }

    func configureCell(post: Post) {
        self.post = post
        
        self.showcaseTxt.text = post.postDescription
        self.likesCount.text = "\(post.postLikes)"
        
    }
    

} 
