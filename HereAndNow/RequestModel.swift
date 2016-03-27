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
            callback(success: true, result: "Done")
        }
    }
    func getRequestedEvents(callback:(success:Bool!, result:[Event]?, error:NSString?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "requests", data: nil) { (result, json) -> Void in
            guard result == true else {
                let error = json!["error"] as! String
                callback(success: false, result:nil, error:error)
                return
            }
            
            callback(success: true, result: nil, error: nil)
        }
    }
    func getRequestsForMyEvent(callback:(success:Bool!, result:String?)->Void) {
        
    }
}
