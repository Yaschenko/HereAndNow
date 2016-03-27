//
//  RequestsViewController.swift
//  HereAndNow
//
//  Created by Yurii on 3/27/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    var requestModel:RequestModel = RequestModel()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.requestModel.getRequestedEvents { (success, result, error) -> Void in
            
        }
    }
}
