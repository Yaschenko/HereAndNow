//
//  EventModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/19/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class Checkin: NSObject {
    var id:Int?
    var can_checkin:Bool?
    var event_id:Int?
    var todays_quota:Int?
    var checked_in:Bool?
    var name:String?
    var data:String?
    var quota_number:Int?
    func checkin(lat:Double, lon:Double, callback:(success:Bool!, result:AnyObject?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "checkins", data: ["checkin_id":"\(self.id!)", "lat":"\(lat)", "long":"\(lon)"]) { (result, json) in
            if result == true, let v = json as? [String:Int] {
                self.quota_number = v["quota_number"]
            }
            callback(success: result, result: json)
        }
    }
}
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
    var userName:String?
    var userEmail:String?
    var userPhone:String?
    var userFB:String?
    
    var title:String?
    var thumb:String?
    var isPublic:Bool = true
    var createDate:NSDate = NSDate()
    var isSendRequest:Bool = false
    var type = "common"
    var checkin : Checkin?
    func canCheckin() -> Bool {
        guard let c = self.checkin else {
            return false
        }
        guard let v = c.can_checkin else {
            return false
        }
        return v
    }
    func tryCheckin(lat:Double, lon:Double, callback:(success:Bool!, result:AnyObject?)->Void) {
        guard let c = checkin else {
            return callback(success: false, result: nil)
        }
        c.checkin(lat, lon: lon, callback: callback)
    }
    static func deleteMyEvent () {
        Event.myEvent = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey("MyEvent")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    static func setMyEventFromEvent(event:Event) {
        Event.myEvent = event
        NSUserDefaults.standardUserDefaults().setObject(event.json(true), forKey: "MyEvent")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    static func getActiveEvent(callback:(success:Bool!)->Void) -> Void {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events/active", data: nil) { (result, json) in
            if result == false {
                Event.deleteMyEvent()
                callback(success: false)
            } else {
                guard let j = json as? NSDictionary else {
                    Event.deleteMyEvent()
                    callback(success: false)
                    return
                }
                if let e = Event.event(j) {
                    Event.setMyEventFromEvent(e)
                    callback(success: true)
                }
            }
        }
    }
    func sendRequest(callback:(success:Bool!, result:String?)->Void) {
        RequestModel().createRequest(self, callback: callback)
    }
    func uploadImageFile1(path:String!, presignedUrlH:String!, presignedUrlL:String!, callback:(success:Bool, result:String?)->Void) {
        let fileName:String = "lq_" + NSString(string: path).lastPathComponent
        let urlPreL = NSURL(string: presignedUrlL)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: urlPreL)
        request.HTTPMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue(fileName, forHTTPHeaderField: "AWSKey")
        request.setValue(NSURL(scheme: urlPreL.scheme, host: urlPreL.host, path: urlPreL.path!)?.absoluteString, forHTTPHeaderField: "AWSUploadedPath")
        
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: NSTemporaryDirectory() + "/" + fileName)) { (data, response, error) -> Void in
            callback(success: true, result: nil)
            let fileName:String = NSString(string: path).lastPathComponent
            let urlPreH = NSURL(string: presignedUrlH)!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: urlPreH)
            request.HTTPMethod = "PUT"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.setValue(fileName, forHTTPHeaderField: "AWSKey")
            request.setValue(NSURL(scheme: urlPreH.scheme, host: urlPreH.host, path: urlPreH.path!)?.absoluteString, forHTTPHeaderField: "AWSUploadedPath")
            
            let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: path)) { (data, response, error) -> Void in
//                callback(success: true, result: nil)
            }
            task.resume()
        }
        task.resume()
    }
    
    func uploadEvent(callback:(success:Bool!, result:String?)->Void) {
        let file = self.photo
        self.photo = nil
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "events", data: self.json(false) as? [String:String]) { (result, json) in
            guard let j = json as? NSDictionary else {
                return callback(success: false, result: nil)
            }
            guard result == true else {
                let error = j["error"] as! String
                callback(success: false, result: error)
                return
            }

            self.setValuesFromJson(j)
            Event.setMyEventFromEvent(self)
            if let p = file, let urlH = j["presign_hq"]as? NSDictionary, let urlL = j["presign_lq"] as? NSDictionary {
                self.uploadImageFile1(p, presignedUrlH: urlH["presigned_url"] as! String, presignedUrlL: urlL["presigned_url"] as! String, callback: callback)
                return
            }
            callback(success: true, result: "Done")
        }

//        ServerConnectionsManager.sharedInstance.sendMultipartData(path: "events", file: file, data: self.json(false) as? [String:String]) { (result, json) in
//            guard result == true else {
//                let error = json!["error"] as! String
//                callback(success: false, result: error)
//                return
//            }
//            
//            self.setValuesFromJson(json as! NSDictionary)
//            Event.setMyEventFromEvent(self)
//            callback(success: true, result: "Done")
//        }
    }
    
    func checkEvent()->Bool {
//        if photo == nil {
//            return false
//        }
        if longitude == nil {
            return false
        }
        if latitude == nil {
            return false
        }
        return true
    }
    func json(includeUser:Bool)->NSDictionary? {
        if !self.checkEvent() {
            return nil
        }
        let json:NSMutableDictionary = NSMutableDictionary()
        if let p = self.photo {
            json["photo"] = p
        }
        json["longitude"] = "\(self.longitude!)"
        json["latitude"] = "\(self.latitude!)"
        if let desc = self.eventDescription {
            json["description"] = desc
        }
        if let v = self.video {
            json["video"] = v
        } else {
            json["video"] = ""
        }
        json["distance"] = "\(self.distance)"
        
        if let v = self.thumb {
            json["photo_128x128"] = v
        } else {
            json["photo_128x128"] = ""
        }
        if let v = self.title {
            json["title"] = v
        } else {
            json["title"] = ""
        }
        json["public"] = "\(self.isPublic)"
        if includeUser == true {
            json["id"] = "\(self.id)"

            json["createDate"] = self.createDate
            
            if self.isPublic == true {
                let user:NSMutableDictionary = NSMutableDictionary()
                if let v = self.userEmail {
                    user["email"] = v
                } else {
//                    user["email"] = ""
                }
                if let v = self.userName {
                    user["name"] = v
                } else {
//                    user["name"] = ""
                }
                if let v = self.userPhone {
                    user["phone"] = v
                } else {
//                    user["phone"] = ""
                }
                if let v = self.userFB {
                    user["fb_profile_url"] = v
                }
                user["id"] = "\(self.userId)"
                json["user"] = user
                
            } else {
                let user:NSMutableDictionary = NSMutableDictionary()
                user["id"] = "\(self.userId)"
                json["user"] = user
            }
        }
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
        
        if let k = json.valueForKey("kind") as? String {
            self.type = k
        }
        if let v = json.valueForKey("checkins") as? [[String:AnyObject]] {
            if v.count > 0 {
                let checkin = Checkin()
                checkin.id = v[0]["id"] as? Int
                checkin.can_checkin = v[0]["can_checkin"] as? Bool
                checkin.event_id = v[0]["event_id"] as? Int
                checkin.todays_quota = v[0]["todays_quota"] as? Int
                checkin.checked_in = v[0]["checked_in"] as? Bool
                checkin.name = v[0]["name"] as? String
                checkin.data = v[0]["description"] as? String
                self.checkin = checkin
            }
        }
        if let c = json.valueForKey("createDate") as? NSDate {
            self.createDate = c
        } else {
            self.createDate = NSDate()
        }
        
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
            self.distance = 0
//            return false
        }
        guard let isPublicObj = json.valueForKey("public") else {
            return false
        }
        if isPublicObj.boolValue == true {
            self.isPublic = true
            if let userId = json.valueForKey("user")?.valueForKey("id") as? String{
                self.userId = Int(userId)!
            } else if let userId = json.valueForKey("user")?.valueForKey("id") {
                self.userId = userId as! Int
            } else {
                return false
            }
            self.userEmail = (json.valueForKey("user")?.valueForKey("email") as? String)
            self.userName = (json.valueForKey("user")?.valueForKey("name") as? String)
            self.userPhone = (json.valueForKey("user")?.valueForKey("phone") as? String)
            self.userFB = (json.valueForKey("user")?.valueForKey("fb_profile_url") as? String)
            
        } else {
            self.isPublic = false
            if let userId = json.valueForKey("user")?.valueForKey("id") as? String{
                self.userId = Int(userId)!
            } else if let userId = json.valueForKey("user")?.valueForKey("id") {
                self.userId = userId as! Int
            } else {
                return false
            }
        }

        self.photo = (json.valueForKey("photo") as? String)
        self.thumb = (json.valueForKey("photo_128x128") as? String)
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
enum EventAccessType:Int {
    case PublicOnly, PrivateOnly, All
}
class EventModel: NSObject {
    var range:Double = 200000000
    var longitude:Double
    var latitude:Double
    var page:Int = 0
    var totalObjects:Int = Int.max
    var data:[Event] = []
    var type:String = "all"
    var accessType:EventAccessType = EventAccessType.All
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
        print(data)
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
        var arr:[String:String] = ["longitude":"\(self.longitude)", "latitude":"\(self.latitude)", "page": "\(page)", "range":"\(self.range)" ]
        if self.type != "all" {
            arr["kind"] = self.type
        }
        switch self.accessType {
        case .PrivateOnly:
            arr["public"] = "0"
        case .PublicOnly:
            arr["public"] = "1"
        default:
            break
        }
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events/all", data: arr) { (result, json) -> Void in
            guard let res = (json as? NSDictionary)  else {
                callback(result: false, data: nil, error: "Somethig went wrong.")
                return
            }
            if !result {
                let error = res["error"] as! String
                callback(result: false, data: nil, error: error)
                return
            }
            print(res)
            self.totalObjects = res.valueForKey("total_entries") as! Int
            let events = self.parse(res.valueForKey("events") as! [NSDictionary])
            print(events)
            self.data += events
            self.page = self.page + 1
            callback(result: true, data: events, error: nil)
        }
    }
    func getMyEvents(callback:(result:Bool!, data:[Event]?, error:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events", data: nil) { (result, json) -> Void in
            guard let res = (json as? NSDictionary)  else {
                callback(result: false, data: nil, error: "Somethig went wrong.")
                return
            }
            if !result {
                let error = res["error"] as! String
                callback(result: false, data: nil, error: error)
                return
            }
            let events = self.parse(res.valueForKey("events") as! [NSDictionary])
            callback(result: true, data: events, error: nil)
        }
    }
}
