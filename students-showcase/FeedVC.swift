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

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    var posts = [Post]()
    static var imageCache = NSCache()
    var username = ""
    var profileImg = ""
    

    var imagePicker: UIImagePickerController!
    
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 395
        
        
        
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
                       let post = Post(postKey: key, dictionary: postDict)
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
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            var profileImg: UIImage?
            
            if let URL = post.userImg {
                profileImg = FeedVC.imageCache.objectForKey(URL) as? UIImage
                
            }
            
            cell.configureCell(post, img: img, profileImage: profileImg)
            return cell
        } else {
            return FeedCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 165
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowDetailView", sender: nil)
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true

    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        if let txt = postField.text where txt != "" {
            if let img = imageSelectorImage.image where imageSelected == true  {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = API_KEY.dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    }) {encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: {response in
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                    if let links = info["links"] as? Dictionary<String,AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
//        let userPostRef = 
        
        
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
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera.png")
        imageSelected = false
        
        tableView.reloadData()
        
    }
    
    
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Log out", style: .Destructive, handler: { (action: UIAlertAction!) in
            self.performSegueWithIdentifier("backToLoginView", sender: nil)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
