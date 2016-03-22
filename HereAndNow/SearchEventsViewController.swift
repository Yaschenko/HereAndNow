//
//  SearchEventsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/1/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class SearchEventsViewController: UIViewController, GeoPointDelegate, CustomCollectionViewActionProtocol {
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
        self.generatePoints(20)
    }

    func generatePoints(count:Int) {
        let width:CGFloat = (self.view.frame.width - 30) / 4.0
        let height:CGFloat = (self.view.frame.height - 280)/5.0
        for i in 0...count-1 {
            let x:CGFloat = CGFloat(arc4random_uniform(UInt32(width-15))) + 7 + width * CGFloat(i % 4)
            let y:CGFloat = CGFloat(arc4random_uniform(UInt32(height-15))) + 120 + height * CGFloat(Int (i/4))
            self.addPoint(CGRect(x: x, y: y, width: 25, height: 25))
        }
    }
    func addPoint(frame:CGRect) {
        let point:GeoPointView = UINib(nibName:"GeoPointView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! GeoPointView
        point.geoPointDelegate = self
        point.frame = frame
        self.view.addSubview(point)
        point.prepareView()
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
            self.collectionView.reloadData()
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
            self.point!.startAnimation(false)
        }
        self.point = point
        self.point!.startAnimation(true)
    }
    func collectionView(collectionView: CustomCollectionView!, actionInCell cell: CustomCollectionViewCell, index:Int) {
        print(index)
    }
}
