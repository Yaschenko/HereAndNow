//
//  DetailEventViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/22/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
import CoreLocation

class DetailEventViewController: UIViewController {
    var event:Event?
    var request:Requst?
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var acceptButton:UIButton!
    @IBOutlet weak var rejectButton:UIButton!
    @IBOutlet weak var locationButton:UIButton!
    @IBOutlet weak var textHeight:NSLayoutConstraint!
    @IBOutlet weak var titleHeight:NSLayoutConstraint!
    @IBOutlet weak var checkinValue:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var event:Event
        self.checkinValue.hidden = true
        if let e = self.event {
            event = e
            button.hidden = false
            button.alpha = 1
            if e.isPublic {
                if e.canCheckin(), let location = self.getMainViewController()?.locationManager?.location {
                    let fromLocation = CLLocation(latitude:e.latitude!, longitude:e.longitude!)
                    location.distanceFromLocation(fromLocation)
                    self.checkinValue.hidden = false
                    if let c = e.checkin!.quota_number {
                        self.checkinValue.text = "\(c)"
                        button.hidden = true
                    } else {
                        self.checkinValue.text = e.checkin!.data
                        button.setTitle("CHECK IN", forState: UIControlState.Normal)
                        button.addTarget(self, action: #selector(checkin), forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    
                } else {
                    button.setTitle("SHOW CONTACTS", forState: UIControlState.Normal)
                    button.addTarget(self, action: #selector(DetailEventViewController.showContactas), forControlEvents: UIControlEvents.TouchUpInside)
                }
            }else if e.isSendRequest == true {
                button.enabled = false
                button.setTitle("WAITING FOR COMFIRMATION", forState: UIControlState.Normal)
                button.alpha = 0.5
            }else{
                button.setTitle("SEND REQUEST", forState: UIControlState.Normal)
                button.addTarget(self, action: #selector(DetailEventViewController.sendRequest), forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else if let r = self.request {
            event = r.event!
            if r.status == "pending" {
                switch r.type {
                case 1:
                    button.enabled = false
                    button.setTitle("WAITING FOR COMFIRMATION", forState: UIControlState.Normal)
                    button.alpha = 0.5
                    break
                default:
                    button.hidden = true
                    acceptButton.hidden = false
                    rejectButton.hidden = false
                }
            } else if r.status == "approved" {
                button.hidden = false
                button.alpha = 1
                button.setTitle("SHOW CONTACTS", forState: UIControlState.Normal)
                button.addTarget(self, action: #selector(DetailEventViewController.showContactas), forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            return
        }
        
        titleLabel.text = event.title
        button.layer.cornerRadius = button.bounds.height/2
        rejectButton.layer.cornerRadius = rejectButton.bounds.height / 2
        acceptButton.layer.cornerRadius = acceptButton.bounds.height / 2
        locationButton.setTitle(String(format: "%0.0f", event.distance), forState: UIControlState.Normal)
        self.descriptionLabel.text = event.eventDescription
        if let photo = event.photo {
            ImageDownloadModel.sharedInstance.downloadImage(photo, callback: { (file, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let err = error {
                        LocalNotificationManager.showError(err, inViewController: self, completion: { () -> Void in
                            
                        })
                        return
                    }
                    guard let path = file else {
                        LocalNotificationManager.showError("Something went wrong.", inViewController: self, completion: { () -> Void in
                            
                        })
                        return
                    }
                    guard let data = NSData(contentsOfURL: path) else {
                        print("no data")
                        return
                    }
                    self.image.image = UIImage(data: data)
                })
            })
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let e = self.event else {
            return
        }
        self.titleHeight.constant = e.title!.textHeight(forWidth: self.titleLabel.frame.width-10, font: self.titleLabel.font)+17
        self.textHeight.constant = e.eventDescription!.textHeight(forWidth: self.descriptionLabel.frame.width-10, font: self.descriptionLabel.font)+17
        self.view.layoutIfNeeded()
    }
    func checkin() {
        if self.event!.canCheckin(), let _ = self.getMainViewController()?.locationManager?.location {
            self.event!.tryCheckin(/*location.coordinate.latitude*/7.21462, lon: 51.4748/*location.coordinate.longitude*/, callback: { (success, result) in
                print(result)
                if success == false {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        LocalNotificationManager.showError("Sorry, you cannot checkin here now. Please, try late.", inViewController: self, completion:nil)
                    })
                } else if let v = result as? [String:Int] {
                    dispatch_async(dispatch_get_main_queue(), {
                        let c = v["quota_number"]!
                        self.checkinValue.text = "\(c)"
                        self.button.hidden = true
                    })
                }
            })
        }
    }
    @IBAction func hide() {
        self.hideModalController()
    }
    @IBAction func showContactas() {
        let VC:ContactsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ContactsViewController") as! ContactsViewController
        guard let e = self.event else {
            return
        }
        VC.event = e
        self.displayFullScreenModalController(VC)
    }
    @IBAction func sendRequest() {
        if let e = self.event {
            e.sendRequest({ (success, result) -> Void in
                if success == true {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        e.isSendRequest = true
                        self.hide()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        LocalNotificationManager.showError(result, inViewController: self, completion: { () -> Void in
                            
                        })
                    })
                }
            })
        }
    }
    @IBAction func showMap() {
        guard let e = self.event else {
            return
        }
        if e.isPublic {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?address=\(e.latitude!),\(e.longitude!)")!)
        }
        
    }
    @IBAction func accept() {
        guard let r = self.request else {
            return
        }
        r.accept { (success, result) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success == true {
                    self.hide()
                } else {
                    LocalNotificationManager.showError(result, inViewController: self, completion: { 
                        
                    })
                }
            })
        }
    }
    @IBAction func reject() {
        guard let r = self.request else {
            return
        }
        r.reject() { (success, result) in
            dispatch_async(dispatch_get_main_queue(), {
                if success == true {
                    self.hide()
                } else {
                    LocalNotificationManager.showError(result, inViewController: self, completion: {
                        
                    })
                }
            })
        }
    }
}
