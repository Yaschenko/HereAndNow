//
//  ImageDownloadModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/21/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class ImageDownloadModel: NSObject {
    private static var imageCashe:[String:NSURL?] = [String:NSURL]()
    static let sharedInstance:ImageDownloadModel = ImageDownloadModel()
    func downloadImage(url:String, callback:(file:NSURL?, error:String?)->Void) {
        if let filePath = ImageDownloadModel.imageCashe[url] {
            callback(file: filePath, error: nil)
            return
        }
        NSURLSession.sharedSession().downloadTaskWithURL(NSURL(string: url)!, completionHandler: { (file, response, error) -> Void in
            callback(file: file, error: error?.localizedDescription)
            guard let path = file else {
                return
            }
            if let tempData = NSData(contentsOfURL: path) {
                let fileName:String = NSTemporaryDirectory()+String(format: "%0.0f.png", NSDate().timeIntervalSince1970)
                if tempData.writeToFile(fileName, atomically: true) {
                    self.setCashe(url, fileUrl: NSURL(fileURLWithPath: fileName))
                }
            }
        }).resume()
    }
    func setCashe(url:String, fileUrl:NSURL) {
        ImageDownloadModel.imageCashe[url] = fileUrl
    }
}
