//
//  MainViewControllerSegue.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MainViewControllerSegue: UIStoryboardSegue {
    
    override func perform() {
        let mainViewController = self.sourceViewController as! MainViewController
        let destinationViewController = self.destinationViewController as! UINavigationController
        //let destinationRootViewController = destinationViewController.viewControllers[0]
        
        if mainViewController.currentViewController != nil {
            mainViewController.currentViewController?.willMoveToParentViewController(nil)
            mainViewController.currentViewController?.view.removeFromSuperview()
            mainViewController.currentViewController?.removeFromParentViewController()
        }
        
        //destinationViewController.view.frame = mainViewController.containerView.bounds;
        mainViewController.addChildViewController(destinationViewController)
        mainViewController.containerView.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(mainViewController)
        mainViewController.currentViewController = destinationViewController
    }
}
