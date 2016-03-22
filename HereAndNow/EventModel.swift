//
//  EventModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/19/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class Event: NSObject {

    static var myEvent:Event? = nil
    var eventDescription:String?
    var distance:Double = 0
    var id:Int = 0
    var longitude:Double? = nil
    var latitude:Double? = nil
    var photo:String?
    var video:String?
    var userId:Int = 0
    var title:String?
    func uploadEvent(callback:(success:Bool!, result:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "events", data: self.json()) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result: error)
                return
            }
            
            self.setValuesFromJson(json as! NSDictionary)
            Event.myEvent = self
            NSUserDefaults.standardUserDefaults().setObject(self.json(), forKey: "MyEvent")
            NSUserDefaults.standardUserDefaults().synchronize()
            callback(success: true, result: "Done")
        }
    }
    
    func checkEvent()->Bool {
        if photo == nil {
            return false
        }
        if longitude == nil {
            return false
        }
        if latitude == nil {
            return false
        }
        return true
    }
    func json()->[String:String]? {
        if !self.checkEvent() {
            return nil
        }
        var json:[String:String] = [String:String]()
        json["photo"] = self.photo!
        json["longitude"] = "\(self.longitude!)"
        json["latitude"] = "\(self.latitude!)"
        if let desc = self.eventDescription {
            json["description"] = desc
        }
        if let v = self.video {
            json["video"] = v
        }
        json["user_id"] = "\(self.userId)"
        json["distance"] = "\(self.distance)"
        json["id"] = "\(self.id)"
        if let v = self.video {
            json["title"] = v
        } else {
            json["title"] = ""
        }
//        json["title"] = "sadasd"
        return json
        
    }
    func setValuesFromJson(json:NSDictionary) -> Bool {
        self.eventDescription = (json.valueForKey("description") as? String)
        if let id = json.valueForKey("id") as? String{
            self.id = Int(id)!
        } else if let id = json.valueForKey("id") {
            self.id = id as! Int
        } else {
            return false
        }
        
        guard let t = json.valueForKey("title") else {
            return false
        }
        self.title = t as? String
        
        if let latitude = json.valueForKey("latitude") as? String{
            self.latitude = Double(latitude)!
        } else if let latitude = json.valueForKey("latitude") {
            self.latitude = latitude as? Double
        } else {
            return false
        }
        
        if let longitude = json.valueForKey("longitude") as? String{
            self.longitude = Double(longitude)!
        } else if let longitude = json.valueForKey("longitude") {
            self.longitude = longitude as? Double
        } else {
            return false
        }
        
        if let distance = json.valueForKey("distance") as? String{
            self.distance = Double(distance)!
        } else if let distance = json.valueForKey("distance") {
            self.distance = distance as! Double
        } else {
            return false
        }
        
        if let userId = json.valueForKey("user_id") as? String{
            self.userId = Int(userId)!
        } else if let userId = json.valueForKey("user_id") {
            self.userId = userId as! Int
        } else {
            return false
        }
        
        
        self.photo = (json.valueForKey("photo") as? String)
        return true
    }
    static func event(json:NSDictionary) -> Event? {
        let event = Event()
       
        if event.setValuesFromJson(json) {
            return event
        } else {
            return nil
        }
    }
}
class EventModel: NSObject {
    var range:Double = 200000000
    var longitude:Double
    var latitude:Double
    var page:Int = 0
    var totalObjects:Int = Int.max
    var data:[Event] = []
    var type:String = "common"
    init(longitude:Double, latitude:Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    func loadEvents(callback:(result:Bool!, data:[Event]?, error:String?)->Void) {
        self.loadEvents(self.type, page: self.page+1, callback: callback)
    }
    func reset() {
        page = 0
        data = []
    }
    private func parse(data:[NSDictionary])->[Event] {
        var events:[Event] = []
        for jsonObj in data {
            guard let event = Event.event(jsonObj) else {
                continue
            }
            events.append(event)
        }
        return events
    }
    private func loadEvents(type:String!, page:Int, callback:(result:Bool!, data:[Event]?, error:String?)->Void) {
        if self.data.count >= self.totalObjects {
            callback(result: true, data: [], error: nil)
            return
        }
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events/all", data: ["kind":type, "longitude":"\(self.longitude)", "latitude":"\(self.latitude)", "page": "\(page)", "range":"\(self.range)" ]) { (result, json) -> Void in
            if !result {
                let error = json!["error"] as! String
                callback(result: false, data: nil, error: error)
                return
            }
            guard let res = (json as? NSDictionary)  else {
                callback(result: false, data: nil, error: "Somethig went wrong.")
                return
            }
            self.totalObjects = res.valueForKey("total_entries") as! Int
            let events = self.parse(res.valueForKey("events") as! [NSDictionary])
            self.data += events
            self.page = self.page + 1
            callback(result: true, data: events, error: nil)
        }
    }
    func getMyEvents(callback:(result:Bool!, data:[Event]?, error:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events", data: nil) { (result, json) -> Void in
            if !result {
                let error = json!["error"] as! String
                callback(result: false, data: nil, error: error)
                return
            }
            guard let res = (json as? NSDictionary)  else {
                callback(result: false, data: nil, error: "Somethig went wrong.")
                return
            }
            let events = self.parse(res.valueForKey("events") as! [NSDictionary])
            callback(result: true, data: events, error: nil)
        }
    }
}
