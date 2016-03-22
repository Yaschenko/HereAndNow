//
//  AuthorizationModel.swift
//  HereAndNow
//
//  Created by Yurii on 3/17/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class AuthorizationModel: NSObject {
    static let sharedInstance:AuthorizationModel = AuthorizationModel()
    func loginWithFacebook(callback:(token:String?, errorString:String?)->Void) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile","email"], fromViewController: nil) { (result, error) -> Void in
            if result.isCancelled {
                callback(token: nil, errorString: "Facebook login was canceled")
                return
            }
            if let errorObj = error {
                callback(token: nil, errorString: errorObj.localizedDescription)
                return
            }
            self.loginWithFBToken(result.token.tokenString, callback: callback)
        }
    }
    private func loginWithFBToken(token:String!, callback:(token:String?, errorString:String?)->Void) {
        ServerConnectionsManager.sharedInstance.sendPostRequest(path: "facebook/login", data: ["token":token]) { (result, json) -> Void in
            guard let jsonObj = json else {
                callback(token: nil, errorString: "Something went wrong. Try agin late.")
                return
            }
            if !result {
                callback(token: nil, errorString: jsonObj.description)
                return
            }
            self.setUser(jsonObj as! [String:String], callback: callback)
        }
    }
    private func setUser(user:[String:String], callback:(token:String?, errorString:String?)->Void) {
        NSUserDefaults.standardUserDefaults().setValue(user["auth_token"], forKey: "auth_token")
        callback(token: user["auth_token"], errorString: nil)
    }
    func isAuthorized() -> Bool {
        if let _ = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") {
            return true
        } else {
            return false
        }
    }
}
