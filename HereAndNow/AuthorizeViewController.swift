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
    @IBOutlet weak var loginButton:UIButton!
    var isAnimating:Bool = false
    let frameDuration:Double = 0.04
    let imagesForAnimation:[[Int]] = [[124, 150],[200, 360],[450, 570],[700, 780],[840, 951]]
    @IBOutlet weak var animationImageViewSuperView:UIView!
    var animationImageView:UIImageView?
    
    var currentIndex:Int! = 0
    var directionRight:Bool = true
    func loadCGImages(from:Int, to:Int) -> [CGImageRef] {
        var images:[CGImageRef] = []
        if from < to {
            for i in from...to {
                if i%2 == 0 {
                    images.append(self.loadImage(i).CGImage!)
                }
            }
        } else {
            for var i = from;i >= to; i-- {
                if i%2 == 0 {
                    images.append(self.loadImage(i).CGImage!)
                }
            }
        }
        return images
    }
    func loadImages(from:Int, to:Int, reverse:Bool) -> [UIImage] {
        var images:[UIImage] = []
        if from < to {
            for i in from...to {
                images.append(self.loadImage(i))
            }
        } else {
            for var i = from;i >= to; i-- {
                images.append(self.loadImage(i))
            }
        }
        return images
    }
    func loadImage(index:Int) -> UIImage {
        let fileName:String = "Onboarding_00\(index)"
            let imgN = /*UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(fileName, ofType: "png")!)*/UIImage(named: fileName)!
            return imgN
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startAnimationForCurrentIndex()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    func createImageView(index:Int) {
        if self.animationImageView != nil {
            self.animationImageView!.layer.removeAllAnimations()
            self.animationImageView!.removeFromSuperview()
            self.animationImageView = nil
        }
        self.animationImageView = UIImageView(image: self.loadImage(index))
        self.animationImageView!.frame = self.animationImageViewSuperView.bounds
        self.animationImageViewSuperView.addSubview(self.animationImageView!)
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.startAnimationForCurrentIndex()
        }
    }
    func startAnimationForCurrentIndex() {
        self.loginButton.hidden = (self.currentIndex != 4)
        var start:Int
        var stop:Int
        start = self.imagesForAnimation[self.currentIndex][0]
        stop = self.imagesForAnimation[self.currentIndex][1]
        self.createImageView(start)
        let anim:CAKeyframeAnimation = CAKeyframeAnimation()
        anim.keyPath = "contents"
        anim.values = self.loadCGImages(start, to: stop)
        anim.repeatCount = Float.infinity
        anim.duration = Double(anim.values!.count) * self.frameDuration
        anim.autoreverses = true
        anim.delegate = self
        self.animationImageView!.layer.addAnimation(anim, forKey: nil)
        isAnimating = false
    }
    func startAnimation() {
        
        if isAnimating {
            return
        }
        print("anim start")
        isAnimating = true
        var start:Int
        var stop:Int
        if self.directionRight {
            start = self.imagesForAnimation[self.currentIndex-1][1]
            stop = self.imagesForAnimation[self.currentIndex][0]
        } else {
            start = self.imagesForAnimation[self.currentIndex+1][0]
            stop = self.imagesForAnimation[self.currentIndex][1]
        }
        self.createImageView(stop)
        
        let anim:CAKeyframeAnimation = CAKeyframeAnimation()
        anim.keyPath = "contents"
        let array = self.loadCGImages(start, to: stop)
        anim.values = array
        anim.repeatCount = 1
        anim.duration = Double(anim.values!.count) * self.frameDuration
        anim.delegate = self
        anim.removedOnCompletion = true
        self.animationImageView!.layer.addAnimation(anim, forKey: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func easyFacebookLogin() {
        AuthorizationModel.sharedInstance.loginWithFacebook { (token, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let errorObj = errorString {
                    LocalNotificationManager.showError(errorObj, inViewController: self, completion:nil)
                } else {
                    self.getMainViewController()!.showCreateEventViewController()
                }
            })
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
    @IBAction func swipeRight(recognizer:UISwipeGestureRecognizer?) {
        if self.isAnimating {
            return
        }
        guard self.currentIndex > 0 else{
            return
        }
        self.directionRight = false
        self.currentIndex = self.currentIndex - 1
        self.startAnimation()
    }
    @IBAction func swipeLeft(recognizer:UISwipeGestureRecognizer?) {
        print("swipe")
        if self.isAnimating {
            print("swipe no")
            return
        }
        guard self.currentIndex < 4 else{
            return
        }
        self.directionRight = true
        self.currentIndex = self.currentIndex + 1
        self.startAnimation()
    }
    
}
