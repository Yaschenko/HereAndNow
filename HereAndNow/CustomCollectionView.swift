//
//  CustomCollectionView.swift
//  HereAndNow
//
//  Created by Yurii on 3/2/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class CustomCollectionView: UIView {
    var firstView:UIView?
    var secondView:UIView?
    var thirdView:UIView?
    var startPosition:CGPoint?
    var width:CGFloat = 0
    let widthK:CGFloat = 0.6
    let distanceK:CGFloat = 0.8
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setSubviewsFrames() {
        if (self.firstView == nil)||(self.secondView == nil)||(self.thirdView == nil) {
            self.prepareSubviews()
        }
        let height:CGFloat = self.frame.height - 30
        self.width = self.frame.width * self.widthK
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width) / 2.0, y: 25, width: self.width, height: height)
        self.secondView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK) / 2.0 , y: 25-10, width: self.width * self.distanceK, height: height * self.distanceK)
        self.thirdView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
    }
    func prepareSubviews() {
        let nib:UINib! = UINib(nibName: "CustomCollectionViewCell", bundle: nil)
        self.firstView = nib.instantiateWithOwner(self, options: nil)[0] as? UIView
        self.secondView = nib.instantiateWithOwner(self, options: nil)[0] as? UIView
        self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.thirdView = nib.instantiateWithOwner(self, options: nil)[0] as? UIView
        self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.addSubview(self.thirdView!)
        self.addSubview(self.secondView!)
        self.addSubview(self.firstView!)
    }
    func startAnimation() {
        let delta:CGFloat = fabs(self.center.x - self.firstView!.center.x)/((self.frame.width + self.width)/2.0)
        let animationTime : Double = Double(0.3 * delta)
        let height:CGFloat = self.frame.height - 30
        UIView.animateWithDuration(animationTime, animations: { () -> Void in
            self.firstView!.center.x = -1 - self.firstView!.frame.width / 2
            self.secondView!.frame = CGRect(x:(self.frame.width - self.width) / 2.0, y: 25, width: self.width, height: height)
            self.thirdView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK) / 2.0 , y: 25-10, width: self.width * self.distanceK, height: height * self.distanceK)
            self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            }) { (result) -> Void in
                self.finishAnimation()
        }
    }
    func finishAnimation() {
        let height:CGFloat = self.frame.height - 30
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.bringSubviewToFront(self.thirdView!)
        self.bringSubviewToFront(self.secondView!)
        let tempVar:UIView = self.firstView!
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
            if self.firstView!.center.x < 100 {
                self.startAnimation()
            }
        default:
//            print(self.startPosition!.x - recognizer.locationInView(self).x)
            var center:CGPoint = self.firstView!.center
            center.x -= self.startPosition!.x - recognizer.locationInView(self).x
            if center.x <= self.center.x {
                self.firstView!.center = center
                self.startPosition = recognizer.locationInView(self)
                self.updateSubviews()
            }
        }
        
    }
    @IBAction func swipeView(recognizer:UISwipeGestureRecognizer) {
        
    }
}
