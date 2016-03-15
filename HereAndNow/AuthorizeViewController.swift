//
//  AuthorizeViewController.swift
//  HereAndNow
//
//  Created by Yurii on 2/22/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit
class IntroCell: UICollectionViewCell {
    @IBOutlet weak var backgraundImageView:UIImageView!
    @IBOutlet weak var textLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var imageView:UIImageView!
}
class AuthorizeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func easyFacebookLogin() {
        
        Backendless.sharedInstance().userService.easyLoginWithFacebookFieldsMapping(["email":"email", "name":"name"], permissions: ["email", "name"],
            response: {(result : NSNumber!) -> () in
                print ("Result: \(result)")
                if self.getMainViewController() != nil {
                    self.getMainViewController()!.showCreateEventViewController()
                }
            },
            error: { (fault : Fault!) -> () in
                print("Server reported an error: \(fault)")
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:IntroCell = collectionView.dequeueReusableCellWithReuseIdentifier("IntroCell", forIndexPath: indexPath) as! IntroCell
        cell.textLabel.text = String(indexPath.row)
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
