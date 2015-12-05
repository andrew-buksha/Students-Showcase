//
//  EditVC.swift
//  Showcase
//
//  Created by Андрей Букша on 05.12.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Firebase

class EditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var changeImgLbl: UILabel!
    
    var post: Post!
    
    var imagePicker: UIImagePickerController!
    var imageChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        postImg.clipsToBounds = true
        print(post)
        
        descriptionTxt.text = post.postDescription
        var img: UIImage?
        
        if let url = post.imageUrl {
            img = FeedVC.feedCache.objectForKey(url) as? UIImage
            postImg.image = img
            postImg.contentMode = .ScaleAspectFill
        } else {
            changeImgLbl.text = "Add image (Optional)"
            postImg.image = UIImage(named: "camera")
            postImg.contentMode = .Center
        }

    }
    
    func updatePost(imgUrl: String?) {
        
        var postDict: Dictionary<String,AnyObject> = [
            "description": descriptionTxt.text!,
            "likes": post.postLikes,
            "username": post.username,
        ]
        
        if post.userImg != nil {
            postDict["profileImg"] = post.userImg
        }
        
        if imgUrl != nil {
            postDict["imageUrl"] = imgUrl
        }
        
        post.postRef.setValue(postDict)
        post.postRef.setPriority(post.postPriority)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        postImg.image = image
        postImg.contentMode = .ScaleAspectFill
        imageChanged = true
    }

    
    @IBAction func savebtnPressed(sender: AnyObject) {
        DataService.ds.uploadData(descriptionTxt.text, imageSelector: postImg, imageSelected: imageChanged) { (result) -> Void in
            if result != "" {
                self.updatePost(result)
            } else {
                if self.post.imageUrl != nil {
                    print("Image didn't change")
                    self.updatePost(self.post.imageUrl)
                } else {
                    print("There wasn't any image")
                    self.updatePost(nil)
                }
            }
        }
        
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}
