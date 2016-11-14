//
//  BaseViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var menuButtonHandler: MenuButtonHandler!
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    
    @IBAction func menuButtonClicked(sender: UIBarButtonItem) {
        self.menuButtonHandler.menuButtonClicked()
    }
    
    func adjustConstraintsForItem(forItem: UIView, toItem: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: forItem,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   relatedBy: NSLayoutRelation.Equal,
                                                   toItem: toItem,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: forItem,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                    toItem: toItem,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: forItem,
                                               attribute: NSLayoutAttribute.Top,
                                               relatedBy: NSLayoutRelation.Equal,
                                               toItem: toItem,
                                               attribute: NSLayoutAttribute.Top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: forItem,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: toItem,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    func contentViewFrame() -> CGRect {
        let screenSize: CGSize = self.viewWillTransitionToSize
        var frame = CGRectMake(0, 64, 320, 504)
        if screenSize.width == 568 {
            frame = CGRectMake(0, 32, 568, 288)
        }
        
        return frame
    }
    
    func isPortraitOrientation() -> Bool {
        return self.viewWillTransitionToSize.width < self.viewWillTransitionToSize.height
    }
    
    func isLandscapeOrientation() -> Bool {
        return !self.isPortraitOrientation()
    }
}
