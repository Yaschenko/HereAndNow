//
//  SearchEventsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/1/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class SearchEventsViewController: UIViewController, GeoPointDelegate, CustomCollectionViewActionProtocol {
    var geoPointViews:[GeoPointView] = []
    var point:GeoPointView?
    var eventsModel:EventModel?
    
    @IBOutlet weak var mapLayer1:UIView!
    @IBOutlet weak var mapLayer2:UIView!
    @IBOutlet weak var mapLayer3:UIView!
    
    @IBOutlet weak var collectionView:CustomCollectionView!
    var data:[AnyObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createEventModel()
        self.collectionView.collectionViewDelegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setMotionEffect(view:UIView, valueX:Int, valueY:Int) {
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = (-1) * valueY
        verticalMotionEffect.maximumRelativeValue = valueY
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = (-1) * valueX
        horizontalMotionEffect.maximumRelativeValue = valueX
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        view.addMotionEffect(group)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.prepareSubviews()
        self.setMotionEffect(self.mapLayer1, valueX: 10, valueY: 3)
        self.setMotionEffect(self.mapLayer2, valueX: 30, valueY: 10)
        self.setMotionEffect(self.mapLayer3, valueX: 50, valueY: 20)
    }
    func addPointAtPosiotion(i:Int, inView view:UIView)->GeoPointView {
        var s:CGFloat = 15
        if view == self.mapLayer3 {
            s = 25
        }
        let width:CGFloat = (view.frame.width - 30) / 4.0
        let height:CGFloat = (view.frame.height - 280)/4.0
        let x:CGFloat = CGFloat(arc4random_uniform(UInt32(width-15))) + 7 + width * CGFloat(i % 4)
        let y:CGFloat = CGFloat(arc4random_uniform(UInt32(height-15))) + 120 + height * CGFloat(Int (i/4))
        let point = self.addPoint(CGRect(x: x, y: y, width: s, height: s), inView: view)
        return point
    }
    func  getLayerForEvent(event:Event!) -> UIView {
        let d = event.distance
        if d < 1000 {
            return self.mapLayer3
        } else if d < 3000 {
            return self.mapLayer2
        } else {
            return self.mapLayer1
        }
    }
    func generatePoints(count:Int) {
        for point in self.geoPointViews {
            point.removeFromSuperview()
        }
        self.geoPointViews.removeAll()
        for i in 0...count-1 {
            let view:UIView = self.getLayerForEvent(self.eventsModel!.data[i])
            self.geoPointViews.append(self.addPointAtPosiotion(i, inView: view))
        }
    }
    func addPoint(frame:CGRect, inView view:UIView) -> GeoPointView {
        let point:GeoPointView = UINib(nibName:"GeoPointView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! GeoPointView
        point.geoPointDelegate = self
        point.frame = frame
        view.addSubview(point)
        point.prepareView()
        return point
    }
    
    func createEventModel() {
        var longitude:Double = 0
        var latitude:Double = 0
        if let location = self.getMainViewController()?.locationManager?.location {
            longitude = location.coordinate.longitude
            latitude = location.coordinate.latitude
        } else if let event = Event.myEvent{
            longitude = event.longitude!
            latitude = event.latitude!
        }
        self.eventsModel = EventModel(longitude: longitude, latitude: latitude)
        self.updateData()
    }
    
    func updateData() {
        
        self.eventsModel!.loadEvents { (result, data, error) -> Void in
            self.collectionView.data = self.eventsModel!.data
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.eventsModel!.data.count == 0 {
                    self.collectionView.hidden = true
                } else {
                    self.collectionView.hidden = false
                    self.collectionView.reloadData()
                    let count = (self.collectionView.data.count > 16) ? 16 : self.collectionView.data.count
                    if self.geoPointViews.count == 0 {
                        self.generatePoints(count)
                    }
                    self.didSelectPoint(self.geoPointViews[0])
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
    func didSelectPoint(point: GeoPointView) {
        if self.point != nil {
            if point == self.point! {
                return
            }
            self.point!.startAnimation(false)
        }
        self.point = point
        self.point!.startAnimation(true)
        self.point?.superview?.bringSubviewToFront(point)
        if self.point!.superview == self.mapLayer1 {
            self.mapLayer2.alpha = 0.6
            self.mapLayer3.alpha = 0.6
        } else if self.point!.superview == self.mapLayer2 {
            self.mapLayer2.alpha = 1
            self.mapLayer3.alpha = 0.6
        } else {
            self.mapLayer2.alpha = 1
            self.mapLayer3.alpha = 1
        }
    }
    func collectionView(collectionView: CustomCollectionView!, actionInCell cell: CustomCollectionViewCell, index:Int) {
        let VC:DetailEventViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailPublicEventViewController") as! DetailEventViewController
        if collectionView.data.count > index {
            VC.event = collectionView.data[index]
            self.displayModalController(VC)
        }
    }
    func collectionView(collectionView: CustomCollectionView!, showCellAtIndex index: Int) {
        if index > collectionView.data.count - 5 {
            self.updateData()
        }
        var point : GeoPointView
        if index >= self.geoPointViews.count {
            let i = index % self.geoPointViews.count
            point = self.geoPointViews[i]
            let view:UIView = self.getLayerForEvent(self.eventsModel!.data[index])
            point.removeFromSuperview()
            
            self.geoPointViews.removeAtIndex(i)
            point = self.addPointAtPosiotion(i, inView:view)
            self.geoPointViews.insert(point, atIndex: i)
        } else {
            point = self.geoPointViews[index]
            if self.getLayerForEvent(self.eventsModel!.data[index]) != point.superview {
                let view:UIView = self.getLayerForEvent(self.eventsModel!.data[index])
                point.removeFromSuperview()
                self.geoPointViews.removeAtIndex(index)
                point = self.addPointAtPosiotion(index, inView:view)
                self.geoPointViews.insert(point, atIndex: index)
            }
        }
        self.didSelectPoint(point)
    }
}
