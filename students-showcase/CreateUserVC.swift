//
//  CreateUserVC.swift
//  students-showcase
//
//  Created by Андрей Букша on 26.11.15.
//  Copyright © 2015 Андрей Букша. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class CreateUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var usernameText: MaterialTextField!
    
    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        userImg.clipsToBounds = true
        userImg.layer.cornerRadius = userImg.frame.size.width / 2

    }
    
    func createUsername(imgUrl: String?) {
        let username = usernameText.text!
        DataService.ds.REF_USERNAME.setValue(username)
        
        if imgUrl != nil {
            let profileImg = imgUrl
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("profileImg").setValue(profileImg)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        userImg.image = image
        imageSelected = true
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Username required", message: "You need to enter your username", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func finishBtnPressed(sender: AnyObject) {
        
        if let txt = usernameText.text where txt != "" {
            if let img = userImg.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.1)!
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
                                        self.createUsername(imgLink)
                                    }
                                }
                            }
                        })
                    case .Failure(let error):
                        print(error)
                    }
            }
        } else {
            self.createUsername(nil)
        }
        } else {
            showErrorAlert()
        }
        performSegueWithIdentifier("logInWithUser", sender: nil)

    }

    
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

}
