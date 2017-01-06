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
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.removeGestureRecognizer(self.navigationController!.interactivePopGestureRecognizer!)
    }
    
    @IBAction func menuButtonClicked(_ sender: UIBarButtonItem) {
        self.menuButtonHandler.menuButtonClicked()
    }
    
    func adjustConstraintsForItem(_ forItem: UIView, toItem: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: forItem,
                                                   attribute: NSLayoutAttribute.leading,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: toItem,
                                                   attribute: NSLayoutAttribute.leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: forItem,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: toItem,
                                                    attribute: NSLayoutAttribute.trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: forItem,
                                               attribute: NSLayoutAttribute.top,
                                               relatedBy: NSLayoutRelation.equal,
                                               toItem: toItem,
                                               attribute: NSLayoutAttribute.top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: forItem,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: toItem,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    func contentViewFrame() -> CGRect {
        let screenSize: CGSize = self.viewWillTransitionToSize
        var frame: CGRect!
        
        switch screenSize.width {
        case 320:
            frame = CGRect(x: 0, y: 64, width: 320, height: 504)
        case 568:
            frame = CGRect(x: 0, y: 32, width: 568, height: 288)
        case 768:
            frame = CGRect(x: 0, y: 64, width: 768, height: 960)
        case 1024:
            frame = CGRect(x: 0, y: 64, width: 1024, height: 704)
        default:
            break
        }
        
        return frame
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.viewWillTransitionToSize = size
    }
    
    func isPortraitOrientation() -> Bool {
        return self.viewWillTransitionToSize.width < self.viewWillTransitionToSize.height
    }
    
    func isLandscapeOrientation() -> Bool {
        return !self.isPortraitOrientation()
    }
}
