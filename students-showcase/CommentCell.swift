//
//  CommentCell.swift
//  students-showcase
//
//  Created by Андрей Букша on 27.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentTxt: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
