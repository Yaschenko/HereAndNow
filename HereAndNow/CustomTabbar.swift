//
//  CustomTabbarButton.swift
//  HereAndNow
//
//  Created by Yurii on 2/29/16.
//  Copyright © 2016 Nostris. All rights reserved.
//

import UIKit

class CustomTabbarButton: UIView {
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var selectedIndicator:UIImageView!
    @IBOutlet weak var tabbarView:CustomTabbarView?
    func setSelected(selected:Bool) {
        self.selectedIndicator.hidden = !selected
        if selected == true {
            self.button.alpha = 1
        } else {
            self.button.alpha = 0.6
        }
    }
    @IBAction func buttonAction(button:UIButton) {
        self.setSelected(true)
        if self.tabbarView != nil {
            self.tabbarView!.selectItem(self)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
protocol CustomTabbarViewDelegate:NSObjectProtocol {
    func didSelectCustomTabbarItem(item:CustomTabbarButton)
}
class CustomTabbarView: UIView {
    @IBOutlet weak var selectedTabbarItem:CustomTabbarButton?
    weak var customTabbarDelegate:CustomTabbarViewDelegate?
    func selectItem(item:CustomTabbarButton) {
        if (self.selectedTabbarItem != nil) && (self.selectedTabbarItem != item) {
            self.selectedTabbarItem!.setSelected(false)
        }
        self.selectedTabbarItem = item
        if self.customTabbarDelegate != nil {
            self.customTabbarDelegate!.didSelectCustomTabbarItem(item)
        }
    }
}