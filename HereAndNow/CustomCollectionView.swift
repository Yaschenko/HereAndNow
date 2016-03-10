//
//  CustomCollectionView.swift
//  HereAndNow
//
//  Created by Yurii on 3/2/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class CustomCollectionViewCell: UIView {
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var distanceTitle:UILabel!
    override func layoutSubviews() {
        let offset:CGFloat = 0.1 * self.frame.height
        image.frame = CGRect(x: offset, y: offset, width: self.frame.height * 0.8, height: self.frame.height * 0.8)
        image.layer.cornerRadius = self.frame.height * 0.4
        title.frame = CGRect(x: self.frame.height, y: offset, width: self.frame.width - self.frame.height * 1.1, height: self.frame.height * 0.6)
        distanceTitle.frame = CGRect(x: self.frame.height, y: self.frame.height * 0.7, width: self.frame.width - self.frame.height * 1.1, height: self.frame.height * 0.2)
        
    }
}
class CustomCollectionView: UIView {
    var firstView:CustomCollectionViewCell?
    var secondView:CustomCollectionViewCell?
    var thirdView:CustomCollectionViewCell?
    var startPosition:CGPoint?
    var width:CGFloat = 0
    let widthK:CGFloat = 0.6
    let distanceK:CGFloat = 0.8
    var data:[GeoPoint] = []
    var currentIndex:Int! = 0
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func setSubviewsFrames() {
        let height:CGFloat = self.frame.height - 30
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width) / 2.0, y: 25, width: self.width, height: height)
        self.secondView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK) / 2.0 , y: 25-10, width: self.width * self.distanceK, height: height * self.distanceK)
        self.thirdView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
    }
    func setSubviewsBGColor() {
        self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    func prepareSubviews() {
        if (self.firstView == nil)||(self.secondView == nil)||(self.thirdView == nil) {
            let nib:UINib! = UINib(nibName: "CustomCollectionViewCell", bundle: nil)
            self.firstView = nib.instantiateWithOwner(self, options: nil)[0] as? CustomCollectionViewCell
            self.secondView = nib.instantiateWithOwner(self, options: nil)[0] as? CustomCollectionViewCell
            self.thirdView = nib.instantiateWithOwner(self, options: nil)[0] as? CustomCollectionViewCell
            
            self.firstView!.image.layer.masksToBounds = true
            self.secondView!.image.layer.masksToBounds = true
            self.thirdView!.image.layer.masksToBounds = true
            
            self.addSubview(self.thirdView!)
            self.addSubview(self.secondView!)
            self.addSubview(self.firstView!)
        }
        self.setSubviewsBGColor()
        self.width = self.frame.width * self.widthK
        self.setSubviewsFrames()
    }
    func startAnimation() {

        let height:CGFloat = self.frame.height - 30
        let delta:CGFloat = fabs(self.center.x - self.firstView!.center.x)/((self.frame.width + self.width)/2.0)
        if delta > 0.5 {
            self.currentIndex = self.currentIndex + 1
            let animationTime : Double = Double(0.3 * delta)
            UIView.animateWithDuration(animationTime, animations: { () -> Void in
                self.firstView!.center.x = -1 - self.firstView!.frame.width / 2
                self.secondView!.frame = CGRect(x:(self.frame.width - self.width) / 2.0, y: 25, width: self.width, height: height)
                self.thirdView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK) / 2.0 , y: 25-10, width: self.width * self.distanceK, height: height * self.distanceK)
                self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
                }) { (result) -> Void in
                    self.finishAnimation()
                    self.reloadVisibleCells()
                    
            }
        } else {
            let animationTime : Double = Double(0.3 * (1-delta))
            UIView.animateWithDuration(animationTime, animations: { () -> Void in
                self.setSubviewsFrames()
                self.setSubviewsBGColor()
                }, completion: { (result) -> Void in
                    
            })
        }
        print(self.currentIndex)
    }
    func setData(data:GeoPoint!, cell:CustomCollectionViewCell!) {
        cell.image.image = UIImage(named:"profile-icon")
    }
    func reloadVisibleCells() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.setData(GeoPoint(), cell: self.firstView!)
            self.setData(GeoPoint(), cell: self.secondView!)
            self.setData(GeoPoint(), cell: self.thirdView!)
        }
    }
    func finishAnimation() {
        let height:CGFloat = self.frame.height - 30
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.bringSubviewToFront(self.thirdView!)
        self.bringSubviewToFront(self.secondView!)
        let tempVar:CustomCollectionViewCell = self.firstView!
        self.firstView = self.secondView
        self.secondView = self.thirdView
        self.thirdView = tempVar
    }
    func getValue(min:CGFloat, max:CGFloat, percent:CGFloat) -> CGFloat {
        return min + (max - min) * percent
    }
    func updateSubviews() {
        let height:CGFloat = self.frame.height - 30
        let delta:CGFloat = fabs(self.center.x - self.firstView!.center.x)/((self.frame.width + self.width)/2.0)
        var width:CGFloat = self.getValue(self.width * self.distanceK, max: self.width, percent: delta)
//        print(delta)
        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.1, max: 1, percent: (1-delta)))
        
        self.secondView!.frame = CGRect(x:(self.frame.width - width) / 2.0 , y: self.getValue(25-10, max: 25, percent: delta), width: width, height: self.getValue(height * self.distanceK, max: height, percent: delta))
        self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.5, max: 1, percent: delta))
        
        width = self.getValue(self.width * self.distanceK * self.distanceK, max: self.width * self.distanceK, percent: delta)
        self.thirdView!.frame = CGRect(x:(self.frame.width - width) / 2.0 , y: self.getValue(25-20, max: 25-10, percent: delta), width: width, height: self.getValue(height * self.distanceK * self.distanceK, max: height * self.distanceK, percent: delta))
        self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.25, max: 0.5, percent: delta))
        
    }
    @IBAction func panView(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Began :
            self.startPosition = recognizer.locationInView(self)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled, UIGestureRecognizerState.Failed :
            self.startAnimation()
        default:
            var center:CGPoint = self.firstView!.center
            center.x -= self.startPosition!.x - recognizer.locationInView(self).x
            if center.x <= self.center.x {
                if self.currentIndex + 1 < self.data.count-1+100 {
                    
                } else {
                    center.x = self.center.x
                }
            } else {
                if (self.currentIndex > 0) {
                    center.x -= (self.frame.width + self.firstView!.frame.width)/2.0
                    self.currentIndex = self.currentIndex - 1
                    self.reloadVisibleCells()
                } else {
                    center.x = self.center.x
                }
            }
            self.firstView!.center = center
            self.updateSubviews()
            self.startPosition = recognizer.locationInView(self)
        }
        
    }
    
    @IBAction func swipeView(recognizer:UISwipeGestureRecognizer) {
        
    }
    
    func reloadData() {
        self.currentIndex = 0
        self.reloadVisibleCells()
    }
}
