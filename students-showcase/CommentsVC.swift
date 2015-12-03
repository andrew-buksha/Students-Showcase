//
//  DetailVC.swift
//  students-showcase
//
//  Created by Андрей Букша on 25.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentText: MaterialTextField!
    @IBOutlet weak var imageSelector: UIImageView!
    
    var comments = [Comment]()
    var pathKey: String!
    var username = ""
    var profileImg = ""
    static var commentCache = NSCache()
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.tableView.estimatedRowHeight = 200
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelector.image = image
        imageSelected = true
        
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
                img = CommentsVC.commentCache.objectForKey(commentUrl) as? UIImage
            }
            
            var profileImg: UIImage?
            
            if let commentURL = comment.userImg {
                profileImg = CommentsVC.commentCache.objectForKey(commentURL) as? UIImage
                
            }
            
            cell.configureCell(comment, img: img, profileImage: profileImg)
            return cell
        } else {
            return CommentCell()
        }
            
    }
    
    func postToFirebase(imgUrl: String?) {
        
        var post: Dictionary<String,AnyObject> = [
            "description": commentText.text!,
            "likes": 0,
            "username": username,
            "profileImg": profileImg
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
        let firebaseComment = DataService.ds.REF_POSTS.childByAppendingPath(pathKey).childByAppendingPath("comments").childByAutoId()
        firebaseComment.setValue(post)
        let commentRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("comments").childByAppendingPath(firebaseComment.key)
        commentRef.setValue(true)
        commentText.text = ""
        imageSelector.image = UIImage(named: "camera.png")
        imageSelected = false
        
        tableView.reloadData()
        
    }
    
    @IBAction func commentBtnPressed(sender: AnyObject) {
        DataService.ds.uploadData(commentText, imageSelector: imageSelector, imageSelected: imageSelected) { (result) -> Void in
            if result != "" {
                self.postToFirebase(result)
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
}
