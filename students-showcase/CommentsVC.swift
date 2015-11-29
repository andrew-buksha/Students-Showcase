//
//  DetailVC.swift
//  students-showcase
//
//  Created by Андрей Букша on 25.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var comments = [Comment]()
    var pathKey: String!
    var username = ""
    var profileImg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        print(pathKey)
        print(username)
        print(profileImg)
        
        DataService.ds.REF_POSTS.childByAppendingPath(pathKey).childByAppendingPath("comments").observeEventType(.Value, withBlock: { snapshot in
            
            self.comments = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if var postDict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let comment = Comment(commentKey: key, postKey: self.pathKey, dictionary: postDict)
                        self.comments.append(comment)
                    }
                }
            }
            
            self.tableView.reloadData()
        })

    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as? CommentCell {
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let commentUrl = comment.imageUrl {
                img = FeedVC.imageCache.objectForKey(commentUrl) as? UIImage
            }
            
            var profileImg: UIImage?
            
            if let commentURL = comment.userImg {
                profileImg = FeedVC.imageCache.objectForKey(commentURL) as? UIImage
                
            }
            
            cell.configureCell(comment, img: img, profileImage: profileImg)
            return cell
        } else {
            return CommentCell()
        }
            
    }
    
}
