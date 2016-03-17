//
//  CreateEventViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/23/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
import MobileCoreServices

class CreateEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var topPosition:NSLayoutConstraint!
    @IBOutlet weak var textViewHeight:NSLayoutConstraint!
    @IBOutlet weak var accessoryView:UIView!
    @IBOutlet weak var lettersCounterLabel:UILabel!
    @IBOutlet weak var textViewPlaceHolder:UILabel!
    @IBOutlet weak var backgroundChangeViewButton:UIImageView!
    @IBOutlet weak var takeSelfieButton:UIButton!
    @IBOutlet weak var barsListView:UIView!
    @IBOutlet weak var transitionView:UIView!
    var profileImage:UIImage? = nil
    let maxLettersCount:Int! = 100
    var keyboarHeight:CGFloat! = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMainViewController()!.updateMyLocation()
        textView.inputAccessoryView = self.accessoryView
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.layer.masksToBounds = true
//        print(Backendless.sharedInstance().userService.currentUser.getProperty("objectId"))
//        self.createPoint()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func keyboardWillChangeFrame(notification:NSNotification) {
        
        let info  = notification.userInfo!
        let value: NSValue! = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        let rawFrame = value.CGRectValue()
        let keyboardFrame:CGRect = view.convertRect(rawFrame, fromView: nil)
        if keyboardFrame.origin.y < self.view.frame.height {
            self.keyboarHeight = keyboardFrame.height
        } else {
            self.keyboarHeight = 0.0
        }
        self.updateFlexibleConstraints()
//        print("keyboardFrame: \(rawFrame)")
    }
    func keyboardDidHide(notification:NSNotification) {
        self.keyboarHeight = 0.0
        self.updateFlexibleConstraints()
    }
    @IBAction func changeProfileImage(sender:UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            //        imagePicker.showsCameraControls = false
            self.presentViewController(imagePicker, animated: true) { () -> Void in
                
            }
        } else {
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            //        imagePicker.showsCameraControls = false
            self.presentViewController(imagePicker, animated: true) { () -> Void in
                
            }
        }
    }
    func createEventSuccess() {
        self.getMainViewController()!.showTabbarViewController()
    }
    @IBAction func createPoint() {
        return self.createEventSuccess()
        
//        if self.getMainViewController()!.locationManager!.location == nil {
//            UIAlertView(title: "Error", message: "Some problems with Your location.", delegate: nil, cancelButtonTitle: "Done").show()
//            return
//        }
//        if self.textView.text.characters.count == 0 {
//            UIAlertView(title: "Error", message: "Your message is empty. Fill \"Your message\" field please.", delegate: nil, cancelButtonTitle: "Done").show()
//            
//            return
//        }
//        if self.profileImage == nil {
//            UIAlertView(title: "Error", message: "Your profile image is empty.", delegate: nil, cancelButtonTitle: "Done").show()
//            return
//        }
//        let userId:String! = Backendless.sharedInstance().userService.currentUser.getProperty("objectId") as! String
//        let userName:String! = Backendless.sharedInstance().userService.currentUser.getProperty("objectId") as! String
//        Backendless.sharedInstance().fileService.upload("profile/\(userId)", content: UIImageJPEGRepresentation(self.profileImage!, 1), response: { (file:BackendlessFile!) -> Void in
//            let point:GeoPoint! = GeoPoint(point: GEO_POINT(latitude: self.getMainViewController()!.locationManager!.location!.coordinate.latitude, longitude: self.getMainViewController()!.locationManager!.location!.coordinate.longitude), categories: ["geo"], metadata: ["user_id":userId, "public":"1", "imageUrl":file.fileURL, "message":self.textView.text, "userName":userName])
//            Backendless.sharedInstance().geoService.savePoint(point, response: { (point:GeoPoint!) -> Void in
//
//                }, error: { (fault:Fault!) -> Void in
//                    
//            })
//            }) { (fault:Fault!) -> Void in
//                
//        }
        
    }
    func updateFlexibleConstraints() {
        if self.keyboarHeight > 0 {
            self.topPosition.constant = 200 - self.keyboarHeight
        } else {
            self.topPosition.constant = self.keyboarHeight
        }
//        print(self.textView.text.textHeight(forWidth: self.textView.frame.width, font: UIFont.systemFontOfSize(14)))
        self.textViewHeight.constant = self.textView.text.textHeight(forWidth: self.textView.frame.width - 10, font: self.textView.font!) + 17
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (result) -> Void in
        }
    }
    @IBAction func accessoryButtonAction(sender:UIButton) {
        self.view.endEditing(true)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.profileImageView.image = self.profileImage
        self.takeSelfieButton.setImage(nil, forState: UIControlState.Normal)
        self.takeSelfieButton.setTitle("", forState: UIControlState.Normal)
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if self.maxLettersCount - textView.text.characters.count > 0 {
            return true
        } else {
            return false
        }
    }
    func textViewDidChange(textView: UITextView) {
        self.updateFlexibleConstraints()
        self.lettersCounterLabel.text = String(self.maxLettersCount - textView.text.characters.count)
    }
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.textViewPlaceHolder.hidden = true
        return true
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.characters.count == 0 {
            self.textViewPlaceHolder.hidden = false
        }
    }
    @IBAction func changeView(sender:UIButton) {
        self.backgroundChangeViewButton.highlighted = !self.backgroundChangeViewButton.highlighted
        UIView.transitionWithView(self.transitionView, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
            self.barsListView.hidden = !self.barsListView.hidden
            }) { (result) -> Void in
                
        }
    }
}
