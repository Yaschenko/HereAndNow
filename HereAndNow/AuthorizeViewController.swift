//
//  AuthorizeViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/22/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

public extension UIDevice {
    
    var frameRateDev: Int {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return 2//"iPod Touch 5"
        case "iPod7,1":                                 return 2//"iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return 2//"iPhone 4"
        case "iPhone4,1":                               return 2//"iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return 2//"iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return 2//"iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return 1//"iPhone 5s"
        case "iPhone7,2":                               return 1//"iPhone 6"
        case "iPhone7,1":                               return 1//"iPhone 6 Plus"
        case "iPhone8,1":                               return 1//"iPhone 6s"
        case "iPhone8,2":                               return 1//"iPhone 6s Plus"
        case "iPhone8,4":                               return 1//"iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return 2//"iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return 2//"iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return 2//"iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return 2//"iPad Air"
        case "iPad5,3", "iPad5,4":                      return 1//"iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return 2//"iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return 2//"iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return 2//"iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return 1//"iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return 1//"iPad Pro"
        case "AppleTV5,3":                              return 2//"Apple TV"
        case "i386", "x86_64":                          return 1//"Simulator"
        default:                                        return 1//identifier
        }
    }
    
}

import UIKit
import QuartzCore
class IntroCell: UICollectionViewCell {
    @IBOutlet weak var backgraundImageView:UIImageView!
    @IBOutlet weak var textLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var imageView:UIImageView!
}
class AuthorizeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var loginButton:UIButton!
    @IBOutlet weak var pages:UIPageControl!
    var isAnimating:Bool = false
    let frameDuration:Double = 0.03
    let imagesForAnimation:[[Int]] = [[74, 74],[100, 180],[225, 285],[350, 390],[420, 489]]
    @IBOutlet weak var animationImageViewSuperView:UIView!
    let gradientLayer:CAGradientLayer = CAGradientLayer()
    var animationImageView:UIImageView?
    var swipeLayer:CALayer?
    var currentIndex:Int! = 0
    var directionRight:Bool = true
    let colors:[CGColor] = [UIColor(red: 119.0/255.0, green: 207.0/255.0, blue: 207.0/255.0, alpha: 1).CGColor, UIColor(red: 229.0/255.0, green: 75.0/255.0, blue: 189.0/255.0, alpha: 1).CGColor,  UIColor(red: 234.0/255.0, green: 209.0/255.0, blue: 121.0/255.0, alpha: 1).CGColor,  UIColor(red: 1, green: 110.0/255.0, blue: 186.0/255.0, alpha: 1).CGColor,  UIColor(red: 119.0/255.0, green: 107.0/255.0, blue: 1, alpha: 1).CGColor,  UIColor(red: 229.0/255.0, green: 75.0/255.0, blue: 189.0/255.0, alpha: 1).CGColor]
    
    let titlesData:[String] = ["Welcome", "Two hours", "Find it on map", "Make a quick", "Go in action"]
    let textsData:[String] = ["Hey, Dude! Now you are the one of SWAMPOFF! My Name Is Mr. Swampoff! You’ve made the right choice! Here is rules of the private club!", "You have just 2 hours to find a party around you! I call it Quicky! Don’t waste your time! Can't you find nada? Waaathchaa! Its SWAMP bwoi! (Lock-out for 2 hours)", "Its not a chat! Blink it! All that you are looking for is around you, Bo-Bo! You can find it on the map! Follow the local Quickies! Let the colored fireflies to guide throw the night!", "Didn’t found anything? Don't be cold fish! Express yourself - Make the cool Quicky! Mdaaa! Go in action! Take a rest - do the bar-quest! Stick around ! - find your discount!", "Heyyaaa! Make a hit! Go offline - there friends and wine!"]
    func loadCGImages(from:Int, to:Int) -> [CGImageRef] {
        var images:[CGImageRef] = []
        if from < to {
            for i in from...to {
                if i % UIDevice.currentDevice().frameRateDev == 0 {
                    images.append(self.loadImage(i).CGImage!)
                }
            }
        } else {
//            for var i = from;i >= to; i -= 1 {
//                if i%2 == 0 {
                    images.append(self.loadImage(to).CGImage!)
//                }
//            }
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
            for var i = from;i >= to; i -= 1 {
                images.append(self.loadImage(i))
            }
        }
        return images
    }
//    func cleanImageData(index:Int) {
//        let fileName:String = String(format:"Onboarding-30fps_00%03i", index)
//        UIImage.remove
//    }
    func loadImage(index:Int) -> UIImage {
        let fileName:String = String(format:"Onboarding-30fps_00%03i", index)
        let imgN = /*UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(fileName, ofType: "png")!)*/UIImage(named: fileName)!
        return imgN
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.insertSublayer(self.gradientLayer, atIndex: 0)
        self.loginButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loginButton.layer.cornerRadius = self.loginButton.bounds.height / 2.0
        
        let gl = self.gradientLayer
        gl.frame = self.view.bounds
        gl.colors = [self.colors[0], self.colors[1]]
        gl.locations = [0.0, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loginButton.layer.cornerRadius = self.loginButton.bounds.height / 2.0
        self.createSwipeLayer()
        self.startAnimationForCurrentIndex()
        let gl = self.gradientLayer
        gl.frame = self.view.bounds
    }
    func createSwipeLayer() {
        let fontSize:CGFloat = 19+5
        let colorTop = UIColor.clearColor().CGColor
        let colorBottom = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).CGColor
        let gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom, colorTop]
        gl.locations = [ 0.0, 0.5, 1]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        gl.frame = CGRect(x: 0, y: 0, width: fontSize, height: fontSize)
        let parentLayer:CALayer = CALayer()
        parentLayer.frame = CGRect(x: 0 ,y: self.view.bounds.height - fontSize - 60 ,width: self.view.bounds.width,height: fontSize)
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: 0,y: 0,width: self.view.bounds.width,height: fontSize)
        textLayer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0).CGColor
        textLayer.foregroundColor = UIColor.blackColor().CGColor
        textLayer.string = "Swipe Left"
        textLayer.fontSize = 13//fontSize-10
        textLayer.font = CGFontCreateWithFontName("HelveticaNeue-Light")
        textLayer.alignmentMode = kCAAlignmentCenter
        parentLayer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6).CGColor
        parentLayer.addSublayer(gl)
        parentLayer.mask = textLayer
        let anim:CABasicAnimation = CABasicAnimation()
        anim.keyPath = "position"
        anim.fromValue = NSValue(CGPoint: CGPoint(x: self.view.bounds.width, y: gl.position.y))
        anim.toValue = NSValue(CGPoint: CGPoint(x: 0, y: gl.position.y))
        anim.repeatCount = Float.infinity
        anim.duration = 2
        gl.addAnimation(anim, forKey: nil)
        self.view.layer.addSublayer(parentLayer)
        self.swipeLayer = parentLayer

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
        if let layer = self.swipeLayer {
            layer.hidden = (self.currentIndex == 4)
        }
        self.pages.hidden = (self.currentIndex == 4)
        
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
    func bgAnimation(duration:Double) {

        let gl = self.gradientLayer
        gl.colors = [self.colors[self.currentIndex], self.colors[self.currentIndex+1]]

        if self.currentIndex > 4 {return}
        if self.currentIndex < 1 {return}
        let anim:CABasicAnimation = CABasicAnimation()
        anim.keyPath = "colors"
        anim.fromValue = [self.colors[self.currentIndex-1], self.colors[self.currentIndex]]//NSValue(CGPoint: CGPoint(x: self.view.bounds.width, y: gl.position.y))
        anim.toValue = [self.colors[self.currentIndex], self.colors[self.currentIndex+1]]//NSValue(CGPoint: CGPoint(x: 0, y: gl.position.y))
        anim.repeatCount = 1
        anim.duration = duration
        anim.removedOnCompletion = true
        gl.addAnimation(anim, forKey: nil)
    }
    func startAnimation() {
        self.pages.currentPage = self.currentIndex
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: self.currentIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        
        if isAnimating {
            return
        }
        if let layer = self.swipeLayer {
            layer.hidden = true
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
        self.bgAnimation(Double(anim.values!.count) * self.frameDuration)
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attrString = NSMutableAttributedString(string: self.textsData[indexPath.row])
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: cell.textLabel.font, range: NSMakeRange(0, attrString.length))
//        cell.textLabel.text = self.textsData[indexPath.row]
        cell.textLabel.attributedText = attrString
        cell.titleLabel.text = self.titlesData[indexPath.row]
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
