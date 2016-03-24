//
//  ContactsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/24/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
enum ContactsType:Int {
    case FB, Phone, Email
    func stringValue()->String {
        switch self {
        case .FB :
            return "Facebook"
        case .Email :
            return "Email"
        case .Phone :
            return "Phone"
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
        let h:CGFloat = 44.0 * 2 + 120
        let offset = (self.view.bounds.height - h) / 2
        self.tableView.contentOffset = CGPoint(x: 0, y: -1 * offset)
        
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
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath)
        if let view = cell.viewWithTag(1) {
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
        }
        if let view = cell.viewWithTag(2) as? UILabel {
            view.text = data[indexPath.row].stringValue()
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.data[indexPath.row].action(self.event)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}
