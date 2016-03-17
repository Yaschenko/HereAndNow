//
//  AuthorizeViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/22/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class IntroCell: UICollectionViewCell {
    @IBOutlet weak var backgraundImageView:UIImageView!
    @IBOutlet weak var textLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var imageView:UIImageView!
}
class AuthorizeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let imagesForAnimation:[[Int]] = [[124, 150],[200, 360],[450, 570],[700, 780],[840, 951]]
    @IBOutlet weak var animationImageView:UIImageView!
    var currentIndex:Int! = 0
    var directionRight:Bool = true
    func loadImages(from:Int, to:Int, reverse:Bool) -> [UIImage] {
        
        var images:[UIImage] = []
        if from < to {
            for i in from...to {
                images.append(UIImage(named: "Onboarding_00\(i)")!)
            }
            if reverse {
                for var i = to;i >= from; i-- {
                    images.append(UIImage(named: "Onboarding_00\(i)")!)
                }
            }
        } else {
            for var i = from;i >= to; i-- {
                images.append(UIImage(named: "Onboarding_00\(i)")!)
            }
            if reverse {
                for i in to...from {
                    images.append(UIImage(named: "Onboarding_00\(i)")!)
                }
            }
        }
        return images
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    func startAnimation() {
        self.animationImageView.animationImages = self.loadImages(124, to: 150, reverse: false)
        self.animationImageView.animationDuration = Double(self.animationImageView.animationImages!.count) * 0.05
        self.animationImageView.startAnimating()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func easyFacebookLogin() {
        AuthorizationModel.sharedInstance.loginWithFacebook { (token, errorString) -> Void in
            if let errorObj = errorString {
                LocalNotificationManager.showError(errorObj, inViewController: self, completion:nil)
            } else {
                
            }
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
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:IntroCell = collectionView.dequeueReusableCellWithReuseIdentifier("IntroCell", forIndexPath: indexPath) as! IntroCell
        cell.textLabel.text = String(indexPath.row)
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    @IBAction func swipeRight(recognizer:UISwipeGestureRecognizer) {
        guard self.currentIndex < 5 else{
            return
        }
        self.directionRight = true
        self.currentIndex = self.currentIndex + 1
        self.startAnimation()
    }
    @IBAction func swipeLeft(recognizer:UISwipeGestureRecognizer) {
        guard self.currentIndex > 0 else{
            return
        }
        self.directionRight = false
        self.currentIndex = self.currentIndex - 1
        self.startAnimation()
    }
}
