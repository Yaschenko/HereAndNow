//
//  GeoPointView.swift
//  HereAndNow
//
//  Created by Yurii on 3/1/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
protocol GeoPointDelegate:NSObjectProtocol {
    func didSelectPoint(point:GeoPointView)
}
class GeoPointView: UIView {
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var widthConstraint:NSLayoutConstraint!
    @IBOutlet weak var button:UIButton!
    weak var geoPointDelegate:GeoPointDelegate?
    private var viewWidth:CGFloat! = 0
    var isAnimated:Bool! = false
    let animationKey: String! = "changeSize"
    func prepareView() {
        self.button.layer.cornerRadius = self.button.frame.width / 2
        self.button.layer.masksToBounds = true
        self.viewWidth = self.frame.width * 2.5
        self.widthConstraint.constant = self.viewWidth
        self.bringSubviewToFront(self.button)
//        self.layoutIfNeeded()
    }
    func startAnimation(animation:Bool) {
//        self.layer.removeAllAnimations()
        self.image.layer.removeAllAnimations()
//        self.button.layer.removeAllAnimations()
        
        if animation == false {
            self.isAnimated = false
            let prevWidth:CGFloat = self.widthConstraint.constant
            self.widthConstraint.constant = self.viewWidth
            
            UIView.animateWithDuration(Double(fabs(self.viewWidth - prevWidth) / (0.6 * self.viewWidth)), animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: { (result) -> Void in
                    
            })
        } else {
            self.isAnimated = true
            widthConstraint.constant = widthConstraint.constant
            self.layoutIfNeeded()
            widthConstraint.constant = 0.6 * widthConstraint.constant
            UIView.beginAnimations(self.animationKey, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationRepeatCount(Float.infinity)
            UIView.setAnimationRepeatAutoreverses(true)
            self.layoutIfNeeded()
            UIView.commitAnimations()
        }
    }
    @IBAction func didSelectAction(button:UIButton) {
        if self.geoPointDelegate != nil {
            self.geoPointDelegate!.didSelectPoint(self)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
