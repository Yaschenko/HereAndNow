//
//  EventModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/19/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class Event: NSObject {
    var eventDescription:String?
    var distance:Double = 0
    var id:Int = 0
    var longitude:Double? = nil
    var latitude:Double? = nil
    var photo:String?
    var video:String?
    var userId:Int = 0
    func uploadEvent(callback:(success:Bool!, result:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "events", data: self.json()) { (result, json) -> Void in
            guard result == true else {
                print(json)
                return
                //                callback()
            }
            
            print(json)
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
        json["photo"] = self.photo
        json["longitude"] = "\(self.longitude)"
        json["latitude"] = "\(self.latitude)"
        if let desc = self.eventDescription {
            json["description"] = desc
        }
        if let v = self.video {
            json["video"] = v
        }
        json["title"] = "sadasd"
        return json
        
    }
    static func event(json:NSDictionary) -> Event? {
        let event = Event()
        event.eventDescription = (json.valueForKey("description") as? String)
        guard let id = json.valueForKey("id") else {
            return nil
        }
        event.id = id as! Int
        
        guard let latitude = json.valueForKey("latitude") else {
            return nil
        }
        event.latitude = latitude as? Double
        
        guard let longitude = json.valueForKey("longitude") else {
            return nil
        }
        event.longitude = longitude as? Double
        
        guard let distance = json.valueForKey("distance") else {
            return nil
        }
        event.distance = distance as! Double
        
        guard let userId = json.valueForKey("user_id") else {
            return nil
        }
        event.userId = userId as! Int
        
        event.photo = (json.valueForKey("photo") as? String)
//        event.photo = (json.valueForKey("photo") as? String)
        
        return event
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
}
