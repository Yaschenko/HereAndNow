//
//  CustomCollectionView.swift
//  HereAndNow
//
//  Created by Yurii on 3/2/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
protocol CustomCollectionViewActionProtocol:NSObjectProtocol {
    func collectionView(collectionView:CustomCollectionView!, actionInCell cell:CustomCollectionViewCell, index:Int)
}
class CustomCollectionViewCell: UIView {
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var distanceTitle:UILabel!
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var delegate:CustomCollectionView!
    @IBOutlet weak var backgroundImage:UIImageView!
    var cellTag:String! = ""
    override func layoutSubviews() {
        let offset:CGFloat = 0.1 * self.frame.height
        let buttonWidth:CGFloat = self.frame.height 
        let buttonHeight:CGFloat = buttonWidth/2.43
        backgroundImage.frame = CGRect(x: self.frame.width * -0.128, y: -0.44*self.frame.height, width: self.frame.width * 1.256, height: 1.983*self.frame.height)
        image.frame = CGRect(x: offset, y: offset, width: self.frame.height * 0.8, height: self.frame.height * 0.8)
        image.layer.cornerRadius = self.frame.height * 0.4
        title.frame = CGRect(x: self.frame.height - 0.5 * offset, y: 2*offset, width: self.frame.width - self.frame.height * 1.1 - buttonWidth, height: self.frame.height * 0.4)
        distanceTitle.frame = CGRect(x: self.frame.height - 0.5 * offset, y: self.frame.height * 0.6, width: self.frame.width - self.frame.height * 1.1 - buttonWidth, height: self.frame.height * 0.2)
        button.frame = CGRect(x: self.frame.width - buttonWidth - offset, y: (self.frame.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        
    }
    
    @IBAction func cellAction(sender:UIButton?) {
        self.delegate.actionInCell(self, sender: sender)
    }
}
class CustomCollectionView: UIView {
    var firstView:CustomCollectionViewCell?
    var secondView:CustomCollectionViewCell?
    var thirdView:CustomCollectionViewCell?
    var startPosition:CGPoint?
    var width:CGFloat = 0
    let widthK:CGFloat = 0.9
    let distanceK:CGFloat = 0.8
    var data:[GeoPoint] = []
    var currentIndex:Int! = 0
    weak var collectionViewDelegate:CustomCollectionViewActionProtocol?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func actionInCell(cell:CustomCollectionViewCell!, sender:UIButton?) {
        if let delegate = self.collectionViewDelegate {
            delegate.collectionView(self, actionInCell:cell, index: self.currentIndex)
        }
    }
    func setSubviewsFrames() {
        let height:CGFloat = self.frame.height - 30
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width) / 2.0, y: 25, width: self.width, height: height)
        self.secondView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK) / 2.0 , y: 25-10, width: self.width * self.distanceK, height: height * self.distanceK)
        self.thirdView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
    }
    func setSubviewsBGColor() {
        self.thirdView!.backgroundImage.alpha = 0.25
        self.secondView!.backgroundImage.alpha = 0.5
        self.firstView!.backgroundImage.alpha = 1
//        self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
//        self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
//        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
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
//                self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//                self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
//                self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
                self.thirdView!.backgroundImage.alpha = 0.5
                self.secondView!.backgroundImage.alpha = 1
                self.firstView!.backgroundImage.alpha = 0.1
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
        cell.distanceTitle.text = data.distance.description
        cell.title.text = data.metadata.valueForKey("userName") as? String
        cell.cellTag = data.metadata.valueForKey("imageUrl") as! String
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: cell.cellTag)!) { (data, response, error) -> Void in
            if let errorV = error {
                print(errorV)
            } else if let dataV = data {
                if cell.cellTag == response!.URL?.absoluteString {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.image.image = UIImage(data: dataV)
                    })
                }
            }

        }.resume()
    }
    func reloadVisibleCells() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if self.data.count > self.currentIndex {
                self.setData(self.data[self.currentIndex], cell: self.firstView!)
            }
            if self.data.count > self.currentIndex + 1 {
                self.setData(self.data[self.currentIndex + 1], cell: self.secondView!)
            }
            if self.data.count > self.currentIndex + 2 {
                self.setData(self.data[self.currentIndex + 2], cell: self.thirdView!)
            }
        }
    }
    func finishAnimation() {
        let height:CGFloat = self.frame.height - 30
        self.firstView!.frame = CGRect(x:(self.frame.width - self.width * self.distanceK * self.distanceK) / 2.0 , y: 25 - 20, width: self.width * self.distanceK * self.distanceK, height: height * self.distanceK * self.distanceK)
//        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        self.firstView!.backgroundImage.alpha = 0.25
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
//        self.firstView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.1, max: 1, percent: (1-delta)))
//        
        self.secondView!.frame = CGRect(x:(self.frame.width - width) / 2.0 , y: self.getValue(25-10, max: 25, percent: delta), width: width, height: self.getValue(height * self.distanceK, max: height, percent: delta))
//        self.secondView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.5, max: 1, percent: delta))
        self.thirdView!.backgroundImage.alpha = self.getValue(0.25, max: 0.5, percent: delta)
        self.secondView!.backgroundImage.alpha = self.getValue(0.5, max: 1, percent: delta)
        self.firstView!.backgroundImage.alpha = self.getValue(0.1, max: 1, percent: (1-delta))
        
        width = self.getValue(self.width * self.distanceK * self.distanceK, max: self.width * self.distanceK, percent: delta)
        self.thirdView!.frame = CGRect(x:(self.frame.width - width) / 2.0 , y: self.getValue(25-20, max: 25-10, percent: delta), width: width, height: self.getValue(height * self.distanceK * self.distanceK, max: height * self.distanceK, percent: delta))
//        self.thirdView!.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: self.getValue(0.25, max: 0.5, percent: delta))
        
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
                if self.currentIndex + 1 < self.data.count {
                    
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