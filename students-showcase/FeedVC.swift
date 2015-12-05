//
//  FeedVC.swift
//  students-showcase
//
//  Created by Андрей Букша on 22.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import IQKeyboardManagerSwift

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var posts = [Post]()
    static var feedCache = NSCache()
    var username = ""
    var profileImg = ""
    

    var imagePicker: UIImagePickerController!
    
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 420
        let button = UIButton()
        button.setImage(UIImage(named: "logout"), forState: .Normal)
        button.frame = CGRectMake(0, 0, 24, 24)
        button.addTarget(self, action: Selector("showLogoutConfirmation"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnItem:UIBarButtonItem = UIBarButtonItem()
        btnItem.customView = button
        self.navigationItem.rightBarButtonItem = btnItem
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.queryOrderedByPriority().observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if var postDict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let priority = snap.priority
                        let post = Post(postPriority: priority, postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.value as? Dictionary<String,AnyObject> {
                if let author = snapshots["username"] as? String {
                    self.username = author
                }
                if let profileImg = snapshots["profileImg"] as? String {
                    self.profileImg = profileImg
                }
                
            }
        })
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as? FeedCell {
            
            cell.request?.cancel()
                        
            var img: UIImage?
            
            if let feedUrl = post.imageUrl {
                img = FeedVC.feedCache.objectForKey(feedUrl) as? UIImage
            }
            
            var profileImg: UIImage?
            
            if let feedURL = post.userImg {
                profileImg = FeedVC.feedCache.objectForKey(feedURL) as? UIImage
                
            }
            
            cell.configureCell(post, img: img, profileImage: profileImg)
            cell.editBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: "goToEditVC:", forControlEvents: .TouchUpInside)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: "showDeleteConfirmation:", forControlEvents: .TouchUpInside)
            return cell
        } else {
            return FeedCell()
        }
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 200
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        performSegueWithIdentifier("ShowCommentsVC", sender: post)
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCommentsVC" {
            if let commentsVC = segue.destinationViewController as? CommentsVC {
                if let post = sender as? Post {
                    commentsVC.pathKey = post.postKey
                    if self.username != "" {
                        commentsVC.username = self.username
                    }
                    if self.profileImg != "" {
                        commentsVC.profileImg = self.profileImg
                    }
                }
            }
        }
        if segue.identifier == "GoToPostEditing" {
            if let editVC = segue.destinationViewController as? EditVC {
                if let post = sender as? Post {
                    editVC.post = post
                }
            }
        }
    }
    
    @IBAction func goToEditVC(sender: UIButton) {
        let post = posts[sender.tag]
        performSegueWithIdentifier("GoToPostEditing", sender: post)
    }
    
    @IBAction func showDeleteConfirmation(sender: UIButton) {
        let post = posts[sender.tag]
        showConfirmation("Delete post", msg: "Are you sure you want to delete post?\n This action can't be canceled.", btnTitle: "Delete") { (success) -> Void in
            post.postRef.removeValue()
        }
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        DataService.ds.uploadData(postField.text, imageSelector: imageSelectorImage, imageSelected: imageSelected) { (result) -> Void in
            if result != "" {
                self.postToFirebase(result)
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    
    
    func postToFirebase(imgUrl: String?) {
        
        
        var post: Dictionary<String,AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "username": username,
            "profileImg": profileImg
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
        let date = NSDate().timeIntervalSince1970
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        firebasePost.setPriority(0 - date)
        let postRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(firebasePost.key)
        postRef.setValue(true)
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera.png")
        imageSelected = false
        
        tableView.reloadData()
        
    }
    
    func showLogoutConfirmation() {
        showConfirmation("Log out", msg: "Are you sure you want to log out?", btnTitle: "Log Out") { (success) -> Void in
            self.performSegueWithIdentifier("backToLoginView", sender: nil)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        }
    }
    
    typealias CompletionHandler = (success: Bool) -> Void
    
    func showConfirmation(alertTitle: String, msg: String, btnTitle: String, completionHandler: CompletionHandler) {
        let alert = UIAlertController(title: alertTitle, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: btnTitle, style: .Destructive, handler: { (action: UIAlertAction!) in
            completionHandler(success: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
