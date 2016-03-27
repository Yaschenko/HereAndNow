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
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.prepareSubviews()
    }
    func addPointAtPosiotion(i:Int)->GeoPointView {
        let width:CGFloat = (self.view.frame.width - 30) / 3.0
        let height:CGFloat = (self.view.frame.height - 280)/3.0
        let x:CGFloat = CGFloat(arc4random_uniform(UInt32(width-15))) + 7 + width * CGFloat(i % 3)
        let y:CGFloat = CGFloat(arc4random_uniform(UInt32(height-15))) + 120 + height * CGFloat(Int (i/3))
        let point = self.addPoint(CGRect(x: x, y: y, width: 15, height: 15))
        return point
    }
    func generatePoints(count:Int) {
        for point in self.geoPointViews {
            point.removeFromSuperview()
        }
        self.geoPointViews.removeAll()
        for i in 0...count-1 {
            self.geoPointViews.append(self.addPointAtPosiotion(i))
        }
    }
    func addPoint(frame:CGRect) -> GeoPointView {
        let point:GeoPointView = UINib(nibName:"GeoPointView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! GeoPointView
        point.geoPointDelegate = self
        point.frame = frame
        self.view.addSubview(point)
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
                    self.generatePoints(9)
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
    }
    func collectionView(collectionView: CustomCollectionView!, actionInCell cell: CustomCollectionViewCell, index:Int) {
        let VC:DetailEventViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailPublicEventViewController") as! DetailEventViewController
        if collectionView.data.count > index {
            VC.event = collectionView.data[index]
            self.displayModalController(VC)
        }
    }
    func collectionView(collectionView: CustomCollectionView!, showCellAtIndex index: Int) {
        var point : GeoPointView
        if index >= self.geoPointViews.count {
            let i = index % self.geoPointViews.count
            point = self.geoPointViews[i]
            point.removeFromSuperview()
            self.geoPointViews.removeAtIndex(i)
            point = self.addPointAtPosiotion(i)
            self.geoPointViews.insert(point, atIndex: i)
        } else {
            point = self.geoPointViews[index]
        }
        self.didSelectPoint(point)
    }
}
