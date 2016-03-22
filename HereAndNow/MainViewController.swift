//
//  ViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/21/16.
//  Copyright © 2016 Nostris. All rights reserved.
//
import CoreLocation
import UIKit
extension String {
    func textHeight(forWidth width:CGFloat, font:UIFont)->CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
extension UIViewController {
    func hideContentController(content:UIViewController) {
        if self.parentViewController != nil {
            self.parentViewController!.hideContentController(self)
        }
    }
    func getMainViewController() -> MainViewController? {
        if self.isKindOfClass(MainViewController) {
            return self as? MainViewController
        } else if self.parentViewController != nil {
            return self.parentViewController!.getMainViewController()
        } else {
            return nil
        }
    }
}
class MainViewController: UIViewController, CLLocationManagerDelegate, CustomTabbarViewDelegate {
    let tabBarViewHeight:CGFloat = 44.0
    var locationManager:CLLocationManager? = nil
    var authViewController:UINavigationController?
    var contentViewController:UIViewController?
    @IBOutlet weak var tabBarHeight:NSLayoutConstraint!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var tabBarView:CustomTabbarView!
    @IBOutlet weak var noLocationView:UIView!
    var needDisplayViewController:UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let json = NSUserDefaults.standardUserDefaults().objectForKey("MyEvent") as? [String:String] {
            if let event = Event.event(json) {
                Event.myEvent = event
            }
        }
        
        
        self.setTabbarVisible(true, animation: false)
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        
        self.updateMyLocation()
        if AuthorizationModel.sharedInstance.isAuthorized() {
            guard let _ = Event.myEvent else {
                self.showCreateEventViewController()
                return
            }
            self.showTabbarViewController()
            
        } else {
            self.showAuthViewController()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getViewController(indentifier:String!) -> UIViewController {
        return self.storyboard!.instantiateViewControllerWithIdentifier(indentifier)
    }
    func showAuthViewController() {
        self.noLocationView.hidden = true
        self.authViewController = self.getViewController("AuthorizeNavigationViewController") as? UINavigationController
        if self.authViewController != nil {
            self.displayContentController(self.authViewController!)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayContentController(content:UIViewController) {
        self.addChildViewController(content)
        content.view.frame = self.contentView.bounds
        self.contentView.addSubview(content.view)
        content.didMoveToParentViewController(self);
    }
    override func hideContentController(content:UIViewController) {
        content.willMoveToParentViewController(nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {            self.updateMyLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.noLocationView.hidden = true
        if let controller = self.needDisplayViewController {
            self.needDisplayViewController = nil
            self.displayContentController(controller)
        }
        
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location manager error \(error)")
    }
    func updateMyLocation() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager!.requestWhenInUseAuthorization()
        } else {
            self.locationManager!.startUpdatingLocation()
        }
    }
    func hideAllControllers() {
        self.tabBarView.customTabbarDelegate = nil
        if self.authViewController != nil {
            self.hideContentController(self.authViewController!)
            self.authViewController = nil
        }
        if self.contentViewController != nil {
            self.hideContentController(self.contentViewController!)
            self.contentViewController = nil
        }
    }
    func showCreateEventViewController() {
        self.hideAllControllers()
        self.contentViewController = self.getViewController("CreateEventNavigationViewController") as? UINavigationController
        if self.locationManager?.location == nil {
            self.noLocationView.hidden = false
            self.needDisplayViewController = self.contentViewController
            return
        }
        self.displayContentController(self.contentViewController!)
    }
    
    func showTabbarViewController() {
        self.hideAllControllers()
        self.contentViewController = self.getViewController("TabbarViewController") as? UITabBarController
        self.setTabbarVisible(false, animation: false)
        self.tabBarView.customTabbarDelegate = self
        if self.locationManager?.location == nil {
            self.noLocationView.hidden = false
            self.needDisplayViewController = self.contentViewController
            return
        }
        self.displayContentController(self.contentViewController!)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    func setTabbarVisible(hidden:Bool, animation:Bool) {
        var newBarHeight:CGFloat = 0
        if hidden == false {
            newBarHeight = self.tabBarViewHeight
        }
        self.tabBarHeight.constant = newBarHeight
        if animation == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (result) -> Void in
                    
            })
        } else {
            self.view.layoutIfNeeded()
        }
        
    }
    func didSelectCustomTabbarItem(item:CustomTabbarButton) {
        (self.contentViewController as! UITabBarController).selectedIndex = item.button.tag
    }
}

