//
//  RequestModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/25/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import Foundation
class Requst: NSObject {
    
}
class RequestModel: NSObject {
    func createRequest(event:Event, callback:(success:Bool!, result:String?)->Void){
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "requests", data: ["event_id":"\(event.id)"]) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result: error)
                return
            }
            
//            self.setValuesFromJson(json as! NSDictionary)
//            Event.myEvent = self
//            NSUserDefaults.standardUserDefaults().setObject(self.json(true), forKey: "MyEvent")
//            NSUserDefaults.standardUserDefaults().synchronize()
            callback(success: true, result: "Done")
        }
    }
}
