//
//  RequestModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/25/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import Foundation
class Requst: NSObject {
    static let kAcceptRequestNotification = "kAcceptRequestNotification"
    static let kRejectRequestNotification = "kRejectRequestNotification"
    
    var id:Int!
    var event:Event?
    var status:String?
    var type:Int = 0
    func setValuesFromJson(json:NSDictionary, type:Int) -> Bool {
        self.type = type
        if let id = json.valueForKey("id") as? String{
            self.id = Int(id)!
        } else if let id = json.valueForKey("id") {
            self.id = id as! Int
        } else {
            return false
        }
        if let e = json["event"] as? NSDictionary {
            self.event = Event.event(e)
            if self.event == nil {
                 return false
            }
        } else if let e = json["from_event"] as? NSDictionary {
            self.event = Event.event(e)
            if self.event == nil {
                return false
            }
        }
        self.status = json.valueForKey("status") as? String
        return true
    }
    func accept(callback:(success:Bool!, result:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: String(format: "requests/\(self.id!)/approve"), data: nil) { (result, json) in
            callback(success: result, result: nil)
            if result == true {
                NSNotificationCenter.defaultCenter().postNotificationName(Requst.kAcceptRequestNotification, object: self)
            }
        }
    }
    func reject(callback:(success:Bool!, result:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: String(format: "requests/\(self.id!)/reject"), data: nil) { (result, json) in
            callback(success: result, result: nil)
            if result == true {
                NSNotificationCenter.defaultCenter().postNotificationName(Requst.kRejectRequestNotification, object: self)
            }
        }
    }
}
class RequestModel: NSObject {
    
    var page:Int = 0
    var totalObjects:Int = Int.max
    var data:[Requst] = []
    var status:String = "pending"
    func createRequest(event:Event, callback:(success:Bool!, result:String?)->Void){
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "requests", data: ["event_id":"\(event.id)"]) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result: error)
                return
            }
            callback(success: true, result: "Done")
        }
    }
    func clearData() {
        self.page = 1
        self.data.removeAll()
    }
    func getRequestedEvents(callback:(success:Bool!, result:[Requst]?, error:NSString?)->Void) {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "requests", data: ["page": "\(page)", "status":self.status]) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result:nil, error:error)
                return
            }
            guard let requests = json?.valueForKey("requests") as? [NSDictionary] else {
                callback(success: false, result: nil, error: "Something went wrong.")
                return
            }
            var array:[Requst] = []
            for request in requests {
                let r = Requst()
                
                if r.setValuesFromJson(request, type: 1) {
                    array.append(r)
                }
            }
            self.totalObjects = json!.valueForKey("total_entries") as! Int
            self.data += array
            self.page = self.page + 1
            callback(success: true, result: array, error: nil)
        }
    }
    func getRequestsForMyEvent(callback:(success:Bool!, result:[Requst]?, error:NSString?)->Void) {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events/requests", data: ["page": "\(page)", "status":self.status]) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result:nil, error:error)
                return
            }
            guard let requests = json?.valueForKey("requests") as? [NSDictionary] else {
                callback(success: false, result: nil, error: "Something went wrong.")
                return
            }
            var array:[Requst] = []
            for request in requests {
                let r = Requst()
                
                if r.setValuesFromJson(request, type: 0) {
                    array.append(r)
                }
            }
            self.totalObjects = json!.valueForKey("total_entries") as! Int
            self.data += array
            self.page = self.page + 1
            callback(success: true, result: array, error: nil)
        }
    }
    func setStatusApproved() {
        self.status = "approved"
    }
    func setStatusPending() {
        self.status = "pending"
    }
}
