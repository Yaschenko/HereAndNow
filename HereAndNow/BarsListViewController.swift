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
    weak var delegate:AnyObject?
    @IBAction func showMore() {
        guard let d = self.delegate else {
            return
        }
        d.showMore(self)
    }
}
class BarsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var isLoading:Bool = false
    @IBOutlet weak var tableView:UITableView!
    var eventsModel:EventModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BarsListViewController.refresh(_:)), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.createEventModel()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.eventsModel else {
            return 0
        }
        return model.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BarTableViewCell = tableView.dequeueReusableCellWithIdentifier("BarCell", forIndexPath: indexPath) as! BarTableViewCell
        cell.delegate = self
        let point:Event = self.eventsModel!.data[indexPath.row]
        cell.barTitle.text = point.title
        cell.barDistance.text = String(format: "%0.3f", point.distance)
        cell.barImageView.tag = indexPath.row
        cell.barImageView.layer.cornerRadius = cell.barImageView.frame.height / 2
        cell.barImageView.layer.masksToBounds = true
        cell.barImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        cell.barImageView.layer.borderWidth = 1
        if let url = point.thumb {
            cell.barImageView.image = nil
            ImageDownloadModel().downloadImage(url, callback: { (file, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let err = error {
                        LocalNotificationManager.showError(err, inViewController: self, completion: { () -> Void in
                            
                        })
                        return
                    }
                    guard let path = file else {
                        LocalNotificationManager.showError("Something went wrong.", inViewController: self, completion: { () -> Void in
                            
                        })
                        return
                    }
                    if indexPath.row == cell.barImageView.tag {
                        guard let data = NSData(contentsOfURL: path) else {
                            print("no data")
                            return
                        }
                        cell.barImageView.image = UIImage(data: data)
                    } else {
                        print("not display")
                    }
                })
            })
        }
        return cell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (self.eventsModel!.data.count - indexPath.row) <= 5 {
            self.refresh(nil)
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
    func refresh(refreshControl: UIRefreshControl?) {
        if self.isLoading {
            return;
        }
        if self.eventsModel == nil {
            return
        }
        
        self.isLoading = true
        if refreshControl != nil {self.eventsModel!.reset()}
        self.eventsModel!.loadEvents { (result, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isLoading = false
                if refreshControl != nil {
                    refreshControl!.endRefreshing()
                }
                
                if error != nil {
                    LocalNotificationManager.showError(error!, inViewController: self, completion: { () -> Void in
                        
                    })
                    return
                }
                guard let events = data else {
                    LocalNotificationManager.showError("Something went wrong.", inViewController: self, completion: { () -> Void in
                        
                    })
                    return
                }
                if events.count > 0 {
                    self.tableView.reloadData()
                }
            })
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    func createEventModel() {
        guard let location = self.getMainViewController()?.locationManager?.location else {
            self.eventsModel = EventModel(longitude: 40, latitude: 40)
            self.eventsModel!.type = "advertisement"
            self.refresh(nil)
            return
        }
        self.eventsModel = EventModel(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
        self.eventsModel!.type = "advertisement"
        self.refresh(nil)
    }
    func showMore(cell:BarTableViewCell) {
        let VC:DetailEventViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailPublicEventViewController") as! DetailEventViewController
        guard let index = self.tableView.indexPathForCell(cell)?.row else {
            return
        }
        if self.eventsModel!.data.count > index {
            VC.event = self.eventsModel!.data[index]
            self.displayModalController(VC)
        }
    }
}
