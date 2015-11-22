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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
