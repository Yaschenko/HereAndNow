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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.getMainViewController()?.locationManager?.location == nil {
            LocalNotificationManager.showError("We cannot get Your location.", inViewController: self, completion: { () -> Void in
                
            })
        }
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
        if self.textView.text.characters.count == 0 {
            LocalNotificationManager.showError("Your message is empty. Fill \"Your message\" field please.", inViewController: self, completion: { () -> Void in
                
            })
            return
        }
//        guard let image = self.profileImage else {
//            LocalNotificationManager.showError("Your profile image is empty.", inViewController: self, completion: { () -> Void in
//                
//            })
//            return
//        }

        let event = Event()
        event.latitude = 40;
        event.longitude = 50;
        event.photo = "https://www.petfinder.com/wp-content/uploads/2012/11/140272627-grooming-needs-senior-cat-632x475.jpg"
        event.eventDescription = self.textView.text
        event.uploadEvent { (success, result) -> Void in
            
        }
        /*
        guard let location = self.getMainViewController()?.locationManager?.location else {
            LocalNotificationManager.showError("We cannot get Your location.", inViewController: self, completion: { () -> Void in
                
            })
            return
        }
        */
//        FileUploadTask().uploadUIIMage(image) { (success, result) -> Void in
//            print(result)
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
