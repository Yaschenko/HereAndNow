//
//  LocalNotificationManager.swift
//  HereAndNow
//
//  Created by Yurii on 3/17/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class LocalNotificationManager: NSObject {

    static func showError(error:String?, inViewController viewController:UIViewController!, completion:(()->Void)?) {
        let alert:UIAlertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            guard let callback = completion else {
                return
            }
            callback()
        }))
        viewController.presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
}
