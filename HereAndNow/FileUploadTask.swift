//
//  FileUploadTask.swift
//  HereAndNow
//
//  Created by Yurii on 3/21/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
import Foundation

class FileUploadTask: NSObject {
    
    var task:NSURLSessionUploadTask? = nil
    
    private func getPresignUrl(fileName:String!, callback:(url:String?, publicUrl:String?, error:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendGetRequest(path: "events/presign_url", data: ["filename":fileName]) { (result, json) -> Void in
            if result == true{
                let url:String? = json!["presigned_url"] as? String
                let publicUrl:String? = json!["public_url"] as? String
                callback(url: url, publicUrl: publicUrl, error: nil)
            } else if let error = json {
                callback(url: nil, publicUrl: nil, error: error["error"] as? String)
            } else {
                callback(url: nil, publicUrl: nil, error: "Something went wrong.")
            }
        }
    }
    func uploadUIIMage(image:UIImage, callback:(success:Bool, result:String?)->Void) {
        let fileName:String = "\(NSDate().timeIntervalSince1970)"
        let path = NSTemporaryDirectory() + "/" + fileName + ".jpeg"
        UIImageJPEGRepresentation(image, 0.6)?.writeToFile(path, atomically: true)
        callback(success: true, result: path)
//        self.uploadPhoto(path, callback: callback)
    }
    func uploadPhoto(path:String!, callback:(success:Bool, result:String?)->Void) {
        self.uploadFile(path, contentType: "image/jpeg", callback: callback)
    }
    func uploadFile(path:String!, contentType:String!, callback:(success:Bool, result:String?)->Void) {
        let fileName:String = NSString(string: path).lastPathComponent
        self.getPresignUrl(fileName) { (url, publicUrl, error) -> Void in
            if let err = error {
                callback(success: false, result: err)
            } else if let presignedUrl = url {
                self.uploadFile(path, into: publicUrl, presignedUrl: presignedUrl, contentType: contentType, callback: callback)
            }
        }
    }
    
    func uploadFile(path:String!, into url:String!, presignedUrl:String!, contentType:String!, callback:(success:Bool, result:String?)->Void) {
        let fileName:String = NSString(string: path).lastPathComponent
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: presignedUrl)!)
        request.HTTPMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(fileName, forHTTPHeaderField: "AWSKey")
        request.setValue(url, forHTTPHeaderField: "AWSUploadedPath")
        
        self.task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: path)) { (data, response, error) -> Void in
            if let err = error {
                callback(success: false, result: err.localizedDescription)
                return
            } else {
                callback(success: true, result: url)
                if contentType == "image/jpeg" {
                    ImageDownloadModel.sharedInstance.setCashe(url, fileUrl: NSURL(fileURLWithPath: path))
                }
            }
        }
        self.task!.resume()
    }
}
