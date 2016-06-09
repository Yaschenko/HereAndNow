//
//  ContactsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/24/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class ContactCell:UITableViewCell {
    var type:Int!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cell = self
        print(cell.bounds)
        if let view = cell.viewWithTag(1) {
            let mLayer:CAShapeLayer = CAShapeLayer()
            if self.type == 1 {
                mLayer.path = UIBezierPath.init(roundedRect: cell.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: 5, height: 5)).CGPath
                view.layer.mask = mLayer
            } else if self.type == 2 {
                mLayer.path = UIBezierPath.init(roundedRect: cell.bounds, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.TopLeft], cornerRadii: CGSize(width: 5, height: 5)).CGPath
                view.layer.mask = mLayer
            } else if self.type == 3 {
                mLayer.path = UIBezierPath.init(roundedRect: cell.bounds, byRoundingCorners: [UIRectCorner.BottomRight, UIRectCorner.BottomLeft], cornerRadii: CGSize(width: 5, height: 5)).CGPath
                view.layer.mask = mLayer
            } else {
                view.layer.mask = nil
            }
            view.layer.masksToBounds = true
        }
    }
}
enum ContactsType:Int {
    case FB, Phone, Email, Sms
    func stringValue()->String {
        switch self {
        case .FB :
            return "Facebook"
        case .Email :
            return "Email"
        case .Phone :
            return "Phone"
        case .Sms :
            return "SMS"
        }
    }
    func action(event:Event!) {
        var url:NSURL?
        switch self {
        case .FB :
            url = NSURL(string: event.userFB!)
        case .Phone :
            url = NSURL(string: "tel://\(event.userPhone!)")
        case .Email :
            url = NSURL(string: "mailto:\(event.userEmail!)")
        case .Sms :
            url = NSURL(string: "sms://\(event.userPhone!)")
        }
        guard let u = url else {
            return
        }
        UIApplication.sharedApplication().openURL(u)
    }
}
class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    var event:Event?
    var data:[ContactsType] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let e = self.event {
            if e.userPhone?.characters.count > 0 {
                data.append(ContactsType.Phone)
            }
            if e.userEmail?.characters.count > 0 {
                data.append(ContactsType.Email)
            }
            if e.userFB?.characters.count > 0 {
                data.append(ContactsType.FB)
            }
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let h:CGFloat = (64.0 * CGFloat(self.data.count)) + 120
        let offset = (self.view.bounds.height - h) / 2
        self.tableView.contentOffset = CGPoint(x: 0, y: -1 * offset)
        self.tableView.scrollEnabled = false
    }
    @IBAction func hide() {
        self.hideFullScreenModalController()
    }
    //
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
        if indexPath.row == 0 && indexPath.row == self.data.count - 1 {
            cell.type = 1
        } else if indexPath.row == 0 {
            cell.type = 2
        } else if indexPath.row == self.data.count - 1 {
            cell.type = 3
        } else {
            cell.type = 0
        }
        if let view = cell.viewWithTag(2) as? UILabel {
            view.text = data[indexPath.row].stringValue()
        }
        if data[indexPath.row] == ContactsType.Phone {
            cell.viewWithTag(10)?.hidden = false
            cell.viewWithTag(11)?.hidden = false
        } else {
            cell.viewWithTag(10)?.hidden = true
            cell.viewWithTag(11)?.hidden = true
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if self.data[indexPath.row] == ContactsType.Phone {
            return;
        }
        self.data[indexPath.row].action(self.event)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    @IBAction func callPhone() {
        ContactsType.Phone.action(self.event)
    }
    @IBAction func sendSms() {
        ContactsType.Sms.action(self.event)
    }
}
