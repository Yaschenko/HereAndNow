//
//  GeoPointView.swift
//  HereAndNow
//
//  Created by Yurii on 3/1/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class RoundView:UIView {
//    override func layoutSubviews() {
////        self.layer.cornerRadius = self.bounds.width/2
//    }
    var color:UIColor?
    override func drawRect(rect: CGRect) {
        let ctx:CGContext = UIGraphicsGetCurrentContext()!;
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents(self.color!.CGColor));
        CGContextFillPath(ctx);
    }
}
protocol GeoPointDelegate:NSObjectProtocol {
    func didSelectPoint(point:GeoPointView)
}
class GeoPointView: UIView {
    @IBOutlet weak var roundView:RoundView!
    @IBOutlet weak var centerView:UIView!
    @IBOutlet weak var widthConstraint:NSLayoutConstraint!
    @IBOutlet weak var button:UIButton!
    weak var geoPointDelegate:GeoPointDelegate?
    private var viewWidth:CGFloat! = 0
    var isAnimated:Bool! = false
    let animationKey: String! = "changeSize"
    override func layoutSubviews() {
//        print("layout")
    }
    func prepareView() {
        
        self.button.layer.cornerRadius = self.button.frame.width / 2
        self.button.layer.masksToBounds = true
        self.viewWidth = self.frame.width
        self.widthConstraint.constant = self.viewWidth
        self.roundView.color = self.roundView.backgroundColor
        self.roundView.backgroundColor = UIColor.clearColor()
//        self.bringSubviewToFront(self.button)
        
        self.layoutIfNeeded()
        self.centerView.layer.cornerRadius = self.centerView.frame.width / 2
    }
    func startAnimation(animation:Bool) {
//        self.layer.removeAllAnimations()
        self.roundView.layer.removeAllAnimations()
//        self.button.layer.removeAllAnimations()
        
        if animation == false {
            self.isAnimated = false
//            let prevWidth:CGFloat = self.widthConstraint.constant
            self.widthConstraint.constant = self.viewWidth
            
//            UIView.animateWithDuration(Double(fabs(self.viewWidth - prevWidth) / (0.6 * self.viewWidth)), animations: { () -> Void in
                self.layoutIfNeeded()
//                }, completion: { (result) -> Void in
//                    
//            })
        } else {
            self.isAnimated = true
            widthConstraint.constant = self.viewWidth
            self.layoutIfNeeded()
            widthConstraint.constant = 5 * self.viewWidth
            UIView.beginAnimations(self.animationKey, context: nil)
            UIView.setAnimationDuration(1.0)
            UIView.setAnimationRepeatCount(Float.infinity)
            UIView.setAnimationRepeatAutoreverses(false)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
            self.layoutIfNeeded()
//            self.roundView.layer.cornerRadius = widthConstraint.constant / 2
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
