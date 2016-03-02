//
//  BarsListViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/27/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class BarTableViewCell: UITableViewCell {
    @IBOutlet weak var barImageView:UIImageView!
    @IBOutlet weak var barTitle:UILabel!
    @IBOutlet weak var barDistance:UILabel!
}
class BarsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    var data:[GeoPoint] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BarTableViewCell = tableView.dequeueReusableCellWithIdentifier("BarCell", forIndexPath: indexPath) as! BarTableViewCell
        let point:GeoPoint = self.data[indexPath.row]
        cell.barTitle.text = point.metadata["city"] as? String
        cell.barDistance.text = String(point.distance.floatValue)
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func updateData() {
        if self.getMainViewController()!.locationManager!.location != nil {
        let query:BackendlessGeoQuery! = BackendlessGeoQuery(point: GEO_POINT(latitude: self.getMainViewController()!.locationManager!.location!.coordinate.latitude, longitude: self.getMainViewController()!.locationManager!.location!.coordinate.longitude), radius:10, units:KILOMETERS, categories: ["geoservice_sample"])
            query.includeMeta(true)
            query.pageSize(20)
            Backendless.sharedInstance().geoService.getPoints(query, response: { (collection:BackendlessCollection!) -> Void in
                print(collection.data)
                self.data = collection.data as! [GeoPoint]
                self.tableView.reloadData()
                }) { (fault:Fault!) -> Void in
                    
            }
        }
    }
    
}
