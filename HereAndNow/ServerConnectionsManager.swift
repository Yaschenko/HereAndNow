//
//  ServerConnectionsManager.swift
//  MyMood
//
//  Created by Yurii on 12/8/15.
//  Copyright © 2015 Nostris. All rights reserved.
//

import Foundation
class ServerConnectionsManager : NSObject, NSURLSessionDelegate{
    var serverUrlString : String!
    lazy var urlSession : NSURLSession! = {return NSURLSession.sharedSession()//NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue:NSOperationQueue.mainQueue())
    }()
    
    lazy var backgroundUrlSession : NSURLSession! = {return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("HereAndNowBGSession"), delegate: self, delegateQueue:NSOperationQueue.mainQueue())}()
    
    init(server : String!) {
        self.serverUrlString = server
    }
    
    func sendRequest(urlRequest:NSURLRequest!, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let task:NSURLSessionDataTask = self.urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
//            guard let r = response as? NSHTTPURLResponse else {
//                callback!(result: false, json: ["error":"Some thing went wrong."])
//                return
//            }
//            if r.statusCode == 401 {
//                print("Not auth")
//                return
//            }
            if data != nil {
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                var json:AnyObject?
                var result:Bool! = true
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                }
                catch {
                    json = ["error":"Some thing went wrong. Cannot serialize json."]
                    result = false
                }
//                if json?.valueForKey("message") != nil {result = false}
                if json?.valueForKey("errors") != nil {
                    result = false
                    json = ["error":json?.valueForKey("errors")?.firstObject as! String]
                }
                if callback != nil{
                    callback!(result: result, json: json)
                }
            } else if let err = error {
                callback!(result: false, json: ["error":err.localizedDescription])
            } else {
                callback!(result: false, json: ["error":"Some thing went wrong. Response data is empty."])
            }
        })
        task.resume();
    }
    func sendMultipartData(path path:String!, file file0:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let file:String = NSString(string: file0).lastPathComponent
        let requestUrl:String! = self.serverUrlString+path
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        let boundarySytring:String! = "Asrf456BGe4h"
        urlRequest.setValue("multipart/form-data; boundary=\(boundarySytring)", forHTTPHeaderField:"Content-Type")
        var httpData:String = ""
        let bodyData:NSMutableData = NSMutableData()
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf("--\(boundarySytring)\r\n")
                httpData.appendContentsOf("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                httpData.appendContentsOf("\(value)\r\n")
            }
        }
        httpData.appendContentsOf("--\(boundarySytring)\r\n")
        httpData.appendContentsOf("Content-Disposition: form-data; name=\"photo\"; filename=\"\(file)\"\r\n")
        httpData.appendContentsOf("Content-Type: image/jpeg\r\n\r\n")
        bodyData.appendData((httpData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        do {
            let string:String = NSTemporaryDirectory().stringByAppendingString(file)
            let dataFile:NSData? = try NSData(contentsOfURL: NSURL(fileURLWithPath: string), options: NSDataReadingOptions.DataReadingMappedIfSafe)
            if dataFile != nil {
                bodyData.appendData(dataFile!)
            }
        }
        catch {
            print(error)
        }
        bodyData.appendData(("--\(boundarySytring)--\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        urlRequest.HTTPBody = bodyData
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
            print("token = " + token!)
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    func sendPostRequest(path path:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        let requestUrl:String! = self.serverUrlString+path
        print("request url = "+requestUrl)
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        var httpData:String = ""
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf(key)
                httpData.appendContentsOf("=")
                httpData.appendContentsOf(value)
                httpData.appendContentsOf("&")
            }
            urlRequest.HTTPBody = (httpData as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        }
        
        urlRequest.HTTPMethod = "POST"
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
            print("token = " + token!)
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    
    func sendGetRequest(path path:String!, data:[String:String]?, callback:((result:Bool!, json:AnyObject?)->Void)?) {
        var requestUrl:String! = self.serverUrlString+path
//        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        var httpData:String = "?"
        if data != nil {
            for (key, value) in data! {
                httpData.appendContentsOf(key)
                httpData.appendContentsOf("=")
                httpData.appendContentsOf(value)
                httpData.appendContentsOf("&")
            }
            requestUrl.appendContentsOf(httpData)
        }
        print(requestUrl)
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: requestUrl)!)
        urlRequest.HTTPMethod = "GET"
        let token:String? = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String
        if token != nil {
            urlRequest.setValue("Token token=\"\(token!)\"", forHTTPHeaderField:"Authorization")
            print("token = " + token!)
        }
        self.sendRequest(urlRequest, callback: callback)
    }
    func downloadFile(urlFile:NSURL, callback:((result:Bool!, json:AnyObject?, response:NSURLResponse?)->Void)?) {
        self.urlSession.downloadTaskWithURL(urlFile) { (url:NSURL?, response:NSURLResponse?, error:NSError?) -> Void in
            print(url?.absoluteString)
            if callback == nil {return}
            if error == nil {
                callback!(result: true, json: url, response: response)
            } else {
                callback!(result: false, json: nil, response: response)
            }
        }.resume()
    }
//    static let sharedInstance = ServerConnectionsManager(server: "http://swampoff.com/api/v1/")
    static let sharedInstance = ServerConnectionsManager(server: "http://52.26.91.181/api/v1/")
}