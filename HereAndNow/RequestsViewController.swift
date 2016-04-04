//
//  RequestsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/27/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var requestModel:RequestModel = RequestModel()
    var requestModelForMyEvents:RequestModel = RequestModel()
    var observer1:AnyObject? = nil
    var observer2:AnyObject? = nil
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var requestedButton:UIButton!
    @IBOutlet weak var confirmedButton:UIButton!
    @IBOutlet weak var loadindicatorView:UIView!
    @IBOutlet weak var noRequestsView:UIView!
    var showPendingEvents:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = Event.myEvent?.title
    }
    func removeRequest(request:Requst) {
        
        guard let i = self.requestModelForMyEvents.data.indexOf(request) else {
            return
        }
        self.requestModelForMyEvents.data.removeAtIndex(i)
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:i, inSection:1)], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadAllRequests()
        weak var weakSelf = self
        self.observer1 = NSNotificationCenter.defaultCenter().addObserverForName(Requst.kAcceptRequestNotification, object: nil, queue: nil) { (notification) in
            guard let s = weakSelf else {
                return
            }
            guard let r = notification.object as? Requst else {
                return
            }
            s.removeRequest(r)
            
        }
        self.observer2 = NSNotificationCenter.defaultCenter().addObserverForName(Requst.kAcceptRequestNotification, object: nil, queue: nil) { (notification) in
            guard let s = weakSelf else {
                return
            }
            guard let r = notification.object as? Requst else {
                return
            }
            s.removeRequest(r)

        }
    }
    override func viewDidDisappear(animated: Bool) {
        if let obs = self.observer1 {
            NSNotificationCenter.defaultCenter().removeObserver(obs)
        }
        if let obs = self.observer2 {
            NSNotificationCenter.defaultCenter().removeObserver(obs)
        }
    }
    func reloadAllRequests() {
        self.requestModel.clearData()
        self.requestModelForMyEvents.clearData()
        self.loadRequests()
    }
    func loadRequests() {
        self.loadindicatorView.hidden = false
        self.requestModel.getRequestedEvents { (success, result, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            self.requestModelForMyEvents.getRequestsForMyEvent({ (success, result, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.loadindicatorView.hidden = true
                })
            })
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.requestModel.data.count == 0 && self.requestModelForMyEvents.data.count == 0 {
            self.noRequestsView.hidden = false
            return 0
        }
        self.noRequestsView.hidden = true
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.requestModel.data.count
        } else {
            return self.requestModelForMyEvents.data.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BarTableViewCell = tableView.dequeueReusableCellWithIdentifier("BarCell", forIndexPath: indexPath) as! BarTableViewCell
        let model = (indexPath.section == 0) ? self.requestModel : self.requestModelForMyEvents
        cell.delegate = self
        let point:Event = model.data[indexPath.row].event!
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "FROM ME"
//        } else {
//            return "FROM PEOPLE"
//        }
//    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        let label:UILabel = UILabel(frame: view.frame)
        view.addSubview(label)
        if section == 0 {
            label.text = "FROM ME"
        } else {
            label.text = "FROM PEOPLE"
        }
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        return view
    }
    func showMore(cell:BarTableViewCell) {
        let VC:DetailEventViewController = self.storyboard!.instantiateViewControllerWithIdentifier("DetailPublicEventViewController") as! DetailEventViewController
        guard let indexPath = self.tableView.indexPathForCell(cell) else {
            return
        }
        let model = (indexPath.section == 0) ? self.requestModel : self.requestModelForMyEvents
        if model.data.count > indexPath.row {
            VC.request = model.data[indexPath.row]
            self.displayModalController(VC)
        }
    }
    @IBAction func showPending() {
        guard self.showPendingEvents != true else {return}
        self.showPendingEvents = true
        self.requestModel.setStatusPending()
        self.requestModelForMyEvents.setStatusPending()
        self.reloadAllRequests()
        self.requestedButton.enabled = false
        self.confirmedButton.enabled = true
    }
    @IBAction func showApproved() {
        guard self.showPendingEvents != false else {return}
        self.showPendingEvents = false
        self.requestModel.setStatusApproved()
        self.requestModelForMyEvents.setStatusApproved()
        self.reloadAllRequests()
        self.requestedButton.enabled = true
        self.confirmedButton.enabled = false
    }
}
