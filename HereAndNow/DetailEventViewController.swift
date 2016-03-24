//
//  DetailEventViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/22/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class DetailEventViewController: UIViewController {
    var event:Event?
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var locationButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let e = self.event else {
            return
        }
        if e.isPublic {
            button.setTitle("SHOW CONTACTS", forState: UIControlState.Normal)
            button.addTarget(self, action: "showContactas", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            button.setTitle("SEND REQUEST", forState: UIControlState.Normal)
            button.addTarget(self, action: "sendRequest", forControlEvents: UIControlEvents.TouchUpInside)
        }
        titleLabel.text = e.title
        button.layer.cornerRadius = button.bounds.height/2
        locationButton.setTitle(String(format: "%0.0f", e.distance), forState: UIControlState.Normal)
        self.descriptionLabel.text = e.eventDescription
        if let photo = event?.photo {
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
    @IBAction func hide() {
        self.hideModalController()
    }
    @IBAction func showContactas() {
        
    }
    @IBAction func sendRequest() {
        
    }
    @IBAction func showMap() {
        guard let e = self.event else {
            return
        }
        if e.isPublic {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?address=\(e.latitude!),\(e.longitude!)")!)
        }
        
    }
}
